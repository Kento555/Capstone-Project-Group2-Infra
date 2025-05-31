# Create CloudWatch Log Group
resource "aws_cloudwatch_log_group" "ce-grp-2-vpc_flow_logs" {
  name              = "/aws/vpc/${module.vpc.vpc_id}/flow-logs"
  retention_in_days = 30 # Adjust retention as needed (1-3653)

  tags = {
    Name = "${var.name_prefix}-vpc-flow-logs-${var.env}"
  }
}

# IAM Role for VPC Flow Logs
resource "aws_iam_role" "ce-grp-2-vpc_flow_log_role" {
  name = "${var.name_prefix}-vpc-flow-log-role-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "vpc-flow-logs.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "${var.name_prefix}-vpc-flow-log-role-${var.env}"
  }
}

# IAM Policy for Flow Logs
resource "aws_iam_role_policy" "ce-grp-2-vpc_flow_log_policy" {
  name = "${var.name_prefix}-vpc-flow-log-policy-${var.env}"
  role = aws_iam_role.ce-grp-2-vpc_flow_log_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      Resource = aws_cloudwatch_log_group.ce-grp-2-vpc_flow_logs.arn
    }]
  })
}

# VPC Flow Logs (CloudWatch Destination)
resource "aws_flow_log" "ce-grp-2-vpc_flow_log" {
  log_destination      = aws_cloudwatch_log_group.ce-grp-2-vpc_flow_logs.arn
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL"
  vpc_id               = module.vpc.vpc_id
  iam_role_arn         = aws_iam_role.ce-grp-2-vpc_flow_log_role.arn

  tags = {
    Name = "${var.name_prefix}-vpc-flow-log-${var.env}"
  }
}
