data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/checkout-lambda.py"
  output_path = "${path.module}/checkout-lambda.zip"
}

# =================== LAMBDA FUNCTION ===================
resource "aws_lambda_function" "order_processor" {
  function_name = "${var.name_prefix}-order-processor-${var.env}"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "checkout-lambda.lambda_handler"
  runtime       = "python3.13"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      PRODUCT_ORDERS_TABLE = aws_dynamodb_table.product_orders_table.name
    }
  }
}

# =================== DEAD LETTER QUEUE ===================
resource "aws_sqs_queue" "order_dlq" {
  name                      = "${var.name_prefix}-order-dlq-${var.env}.fifo"
  fifo_queue                = true
  content_based_deduplication = true
  
  tags = {
    Name        = "${var.name_prefix}-order-dlq-${var.env}"
    Environment = var.env
  }
}

# =================== SNS Topic + Email Subscription ===================
resource "aws_sns_topic" "lambda_alerts" {
  name = "${var.name_prefix}-lambda-alerts-${var.env}"
  tags = {
    Name        = "${var.name_prefix}-lambda-alerts-${var.env}"
    Environment = var.env
  }
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.lambda_alerts.arn
  protocol  = "email"
  endpoint  = "chrisyeohc@outlook.com"
}

# =================== CloudWatch Alarms ===================
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_description   = "Alerts when order_processor Lambda fails to process SQS messages"
  alarm_name          = "${var.name_prefix}-order-processor-errors-${var.env}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_actions       = [aws_sns_topic.lambda_alerts.arn]
  ok_actions          = [aws_sns_topic.lambda_alerts.arn]
  dimensions = {
    FunctionName = aws_lambda_function.order_processor.function_name
  }
  tags = {
    Name        = "${var.name_prefix}-lambda-error-alarm-${var.env}"
    Environment = var.env
  }
}

resource "aws_cloudwatch_metric_alarm" "dlq_alarm" {
  alarm_description   = "Alerts when messages are in Dead Letter Queue"
  alarm_name          = "${var.name_prefix}-dlq-not-empty-${var.env}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "Maximum"
  threshold           = 0  # Triggers if any messages in DLQ
  alarm_actions       = [aws_sns_topic.lambda_alerts.arn]
  ok_actions          = [aws_sns_topic.lambda_alerts.arn]
  dimensions = {
    QueueName = aws_sqs_queue.order_dlq.name
  }
  tags = {
    Name        = "${var.name_prefix}-dlq-alarm-${var.env}"
    Environment = var.env
  }
}

# =================== IAM Role & Policies ===================
resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.name_prefix}-lambda-exec-role-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "lambda_custom_policy" {
  name = "${var.name_prefix}-lambda-custom-policy-${var.env}"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"],
        Resource = aws_sqs_queue.order_queue.arn
      },
      {
        Effect   = "Allow",
        Action   = ["dynamodb:PutItem"],
        Resource = "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${aws_dynamodb_table.product_orders_table.name}"
      },
      {
        Effect   = "Allow",
        Action   = ["sqs:SendMessage"],
        Resource = aws_sqs_queue.order_dlq.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_custom_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_custom_policy.arn
}

# =================== EVENT SOURCE MAPPING WITH DLQ ===================
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn       = aws_sqs_queue.order_queue.arn
  function_name         = aws_lambda_function.order_processor.arn
  batch_size            = 1
  enabled               = true
  function_response_types = ["ReportBatchItemFailures"]
  
  destination_config {
    on_failure {
      destination_arn = aws_sqs_queue.order_dlq.arn
    }
  }
}