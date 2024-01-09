resource "aws_sqs_queue" "sqs_queue" {
  name                      = "${var.project-name}-${var.infra_env}-sqs"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10

  tags = {
    Name        = "${var.project-name}-${var.infra_env}-vpc"
    Project     = "${var.project-name}.com"
    Environment = var.infra_env
    ManagedBy   = "dcgmechanics"
  }
}

resource "aws_sqs_queue_policy" "sqs_policy" {
  queue_url = aws_sqs_queue.sqs_queue.id

  policy = <<POLICY
    {
    "Version": "2012-10-17",
    "Id": "sqspolicy",
    "Statement": [
        {
        "Sid": "First",
        "Effect": "Allow",
        "Principal": "*",
        "Action": "sqs:SendMessage",
        "Resource": "${aws_sqs_queue.sqs_queue.arn}"
        }
    ]
    }
    POLICY
}