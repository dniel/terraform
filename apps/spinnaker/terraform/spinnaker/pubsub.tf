
#####################################################################
# Add SNS and SQS queue for trigging spinnaker pipelines.
# Configure PUBSUB with AWS both S3 artifact and Custom artifact.
#
# Like described on pages
# - https://spinnaker.io/guides/user/pipeline/triggers/pubsub/
# - https://spinnaker.io/setup/triggers/google/
# - https://spinnaker.io/setup/triggers/amazon/
####################################################################
# Bucket to upload trigger to.
resource "aws_s3_bucket" "bucket" {
  bucket = "198596758466-spinnaker-deploy"

  lifecycle_rule {
    id      = "artifacts"
    enabled = true
    expiration {
      days = 30
    }
  }
}

# Sns Topic
resource "aws_sns_topic" "spinnaker_deployment_topic" {
  name = "${var.name_prefix}-spinnaker-deployment"
}

# Notificastion to SNS when ObjectCreated
resource "aws_s3_bucket_notification" "s3_notification_to_sns_topic" {
  bucket = aws_s3_bucket.bucket.id

  topic {
    topic_arn = aws_sns_topic.spinnaker_deployment_topic.arn
    events = [
      "s3:ObjectCreated:*",
    ]
  }
}

# SQS Queue
resource "aws_sqs_queue" "spinnaker_deployment_queue" {
  name                       = "${var.name_prefix}-spinnaker-deployment"
  delay_seconds              = 0
  receive_wait_time_seconds  = 20
  visibility_timeout_seconds = 60
  max_message_size           = 262144
  message_retention_seconds  = 120
  fifo_queue                 = false
}

# Subscribe SQS queue to SNS topic.
resource "aws_sns_topic_subscription" "spinnaker_deployment_subscription" {
  topic_arn = aws_sns_topic.spinnaker_deployment_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.spinnaker_deployment_queue.arn
}

# Allow S3 to Publish event to SNS topic.
resource "aws_sns_topic_policy" "allow_publish_events_from_s3" {
  arn    = aws_sns_topic.spinnaker_deployment_topic.arn
  policy = <<POLICY
  {
      "Version":"2012-10-17",
      "Statement":[ {
          "Effect": "Allow",
          "Principal": {"Service":"s3.amazonaws.com"},
          "Action": "SNS:Publish",
          "Resource":  "${aws_sns_topic.spinnaker_deployment_topic.arn}",
          "Condition":{
              "ArnLike":{"aws:SourceArn":"${aws_s3_bucket.bucket.arn}"}
          }
      }]
  }
  POLICY
}

# Allow SNS topic to SendMessage to SQS queue
resource "aws_sqs_queue_policy" "allow_sendmessage_from_sns_to_sqs" {
  queue_url = aws_sqs_queue.spinnaker_deployment_queue.id
  policy    = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "allow-sns-send",
  "Statement": [
    {
      "Sid": "1",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.spinnaker_deployment_queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.spinnaker_deployment_topic.arn}"
        }
      }
    }
  ]
}
POLICY
}

#####################################################################
# Add SNS and SQS queue for trigging spinnaker pipelines.
# Another SNS and Queue, this time for Direct SNS ctrigger
# and not S3 CreatedEvent trigger like the one above.
####################################################################
# Bucket to upload artifacts to. (not for triggers)
# TODO: need to define a s3 bucket policy
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy
resource "aws_s3_bucket" "bucket_terraform_artifacts" {
  bucket = "198596758466-spinnaker-artifact-uploads"
}

# Sns Topic
resource "aws_sns_topic" "spinnaker_pubsub_custom_topic" {
  name = "${var.name_prefix}-spinnaker-pubsub-custom-artifact"
}

# SQS Queue
resource "aws_sqs_queue" "spinnaker_pubsub_custom_queue" {
  name                       = "${var.name_prefix}-spinnaker-pubsub-custom-artifact"
  delay_seconds              = 0
  receive_wait_time_seconds  = 20
  visibility_timeout_seconds = 60
  max_message_size           = 262144
  message_retention_seconds  = 120
  fifo_queue                 = false
}

# Subscribe SQS queue to SNS topic.
resource "aws_sns_topic_subscription" "spinnaker_pubsub_custom_subscription" {
  topic_arn = aws_sns_topic.spinnaker_pubsub_custom_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.spinnaker_pubsub_custom_queue.arn
}

# Allow SNS topic to SendMessage to SQS queue
resource "aws_sqs_queue_policy" "allow_sendmessage_from_custom_sns_to_custom_sqs" {
  queue_url = aws_sqs_queue.spinnaker_pubsub_custom_queue.id
  policy    = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "allow-sns-send",
  "Statement": [
    {
      "Sid": "1",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.spinnaker_pubsub_custom_queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.spinnaker_pubsub_custom_topic.arn}"
        }
      }
    }
  ]
}
POLICY
}

#####################################################################
# Configure custom templates for ECHO as custom volumes.
# Like described https://spinnaker.io/reference/halyard/custom/#using-custom-volumes
####################################################################
resource "kubernetes_secret" "spinnaker_echo_webhook_templates" {
  metadata {
    name      = "echo-webhook-templates"
    namespace = "spinnaker"
  }
  data = {
  }
}

resource "kubernetes_config_map" "spinnaker_echo_custom_templates" {
  metadata {
    name      = "echo-custom-templates"
    namespace = "spinnaker"
  }
  data = {
    "pubsub_embedded_artifact.json" = file("${path.module}/templates/pubsub_embedded_artifact.json")
    "pubsub_custom_object.json"     = file("${path.module}/templates/pubsub_custom_object.json")
  }
}