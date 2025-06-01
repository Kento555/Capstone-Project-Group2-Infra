resource "aws_sqs_queue" "order_queue" {
  name       = "${var.name_prefix}-order-queue-${var.env}.fifo"
  fifo_queue = true
  # Optional: Enable content-based deduplication (default false)
  content_based_deduplication = true

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Id" : "__default_policy_ID",
    "Statement" : [
      {
        "Sid" : "__owner_statement",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action" : "SQS:*",
        "Resource" : "arn:aws:sqs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${var.name_prefix}-order-queue-${var.env}.fifo"
      }
    ]
  })
}
