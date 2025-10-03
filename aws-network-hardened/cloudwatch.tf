resource "aws_cloudwatch_log_group" "vpc_flow" {
  name              = format("/aws/vpc/flowlogs/%s", aws_vpc.main.id)
  retention_in_days = 30            # tune as needed
  # kms_key_id      = aws_kms_key.logs.arn  # optional
  tags = { Name = "vpc-flow-log-group" }
}

# IAM role for VPC Flow Logs to write to CloudWatch
data "aws_iam_policy_document" "vpc_flow_logs_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "vpc_flow_logs" {
  name               = "vpc-flow-logs-role"
  assume_role_policy = data.aws_iam_policy_document.vpc_flow_logs_assume_role.json
}

data "aws_iam_policy_document" "vpc_flow_logs_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "vpc_flow_logs" {
  name   = "vpc-flow-logs-policy"
  role   = aws_iam_role.vpc_flow_logs.id
  policy = data.aws_iam_policy_document.vpc_flow_logs_policy.json
}

resource "aws_flow_log" "vpc" {
  vpc_id                   = aws_vpc.main.id
  log_destination_type     = "cloud-watch-logs"
  log_destination          = aws_cloudwatch_log_group.vpc_flow.arn
  traffic_type             = "ALL"            # or "REJECT"
  max_aggregation_interval = 60
  iam_role_arn             = aws_iam_role.vpc_flow_logs.arn
  tags = { Name = "vpc-flow-log" }
}