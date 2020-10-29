#####################################################################
# configure spinnaker
#
# TODO
# - add spinnaker terraform provider to create pipelines and stuff
#
####################################################################
locals {
  app_name = "spinnaker"
  labels = merge(var.labels, {
    "app" = local.app_name
  })
  forwardauth_middleware_namespace = var.name_prefix
  forwardauth_middleware_name      = "forwardauth-authorize"
}

data "kubernetes_namespace" "spinnaker" {
  metadata {
    name = "spinnaker"
  }
}

#####################################################################
# Deploy Aromy Spinnaker Operator in Spinnaker namespace.
####################################################################
resource "helm_release" "helm_release_spinnaker_operator" {
  name       = "spinnaker"
  repository = "https://armory.jfrog.io/artifactory/charts/"
  chart      = "armory-spinnaker-operator"

  #version   = "1.2.0-snapshot.fix.ubi.f9afe37"
  namespace = data.kubernetes_namespace.spinnaker.id
}

# Create Alias A records for Spinnaker
resource "aws_route53_record" "spin_alias_record" {
  zone_id = var.hosted_zone_id
  name    = "spin"
  type    = "A"

  alias {
    name                   = "lb.${var.domain_name}"
    zone_id                = var.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "kubernetes_manifest" "middleware_strip_api_prefix" {
  provider = kubernetes-alpha
  manifest = {
    "apiVersion" : "traefik.containo.us/v1alpha1"
    "kind" : "Middleware"
    "metadata" : {
      "labels" : local.labels
      "namespace" : "spinnaker"
      "name" : "strip-api-prefix"
    }
    "spec" : {
      "stripPrefix" : {
        "prefixes" : [
          "/api"
        ]
      }
    }
  }
}

######################################################
# expose spinnaker api
#
######################################################
resource "kubernetes_manifest" "spinnaker_gate_ingressroute" {
  provider   = kubernetes-alpha

  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata" = {
      "annotations" = {
        "kubernetes.io/ingress.class" = "traefik-${var.name_prefix}"
      },
      "namespace" = "spinnaker"
      "labels"    = local.labels
      "name"      = "spin-gate"
    }
    "spec" = {
      "entryPoints" = [
        "websecure",
      ]
      "routes" = [
        {
          "kind"  = "Rule"
          "match" = "Host(`spin.${var.domain_name}`) && PathPrefix(`/api`)"
          "middlewares" = [
            {
              "name"      = "strip-api-prefix"
              "namespace" = "spinnaker"
            },
          ]
          "services" = [
            {
              "name" = "spin-gate"
              "port" = 8084
            },
          ]
        },
      ]
      "tls" = {
        "certResolver" = "default"
      }
    }
  }
}

######################################################
# expose spinnaker ui
#
######################################################
resource "kubernetes_manifest" "spinnaker_deck_ingressroute" {
  provider   = kubernetes-alpha

  manifest = {
    "apiVersion" = "traefik.containo.us/v1alpha1"
    "kind"       = "IngressRoute"
    "metadata" = {
      "annotations" = {
        "kubernetes.io/ingress.class" = "traefik-${var.name_prefix}"
      },
      "namespace" = "spinnaker"
      "labels"    = local.labels
      "name"      = "spin-deck"
    }
    "spec" = {
      "entryPoints" = [
        "websecure",
      ]
      "routes" = [
        {
          "kind"  = "Rule"
          "match" = "Host(`spin.${var.domain_name}`)"
          "middlewares" = [
          ]
          "services" = [
            {
              "name" = "spin-deck"
              "port" = 9000
            },
          ]
        },
      ]
      "tls" = {
        "certResolver" = "default"
      }
    }
  }
}


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
  bucket        = "198596758466-spinnaker-deploy"
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
  message_retention_seconds  = 1209600
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
  arn = aws_sns_topic.spinnaker_deployment_topic.arn
  policy = <<POLICY
  {
      "Version":"2012-10-17",
      "Statement":[{
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
resource "aws_s3_bucket" "bucket_terraform_artifacts" {
  bucket        = "198596758466-spinnaker-artifact-uploads"
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
  message_retention_seconds  = 1209600
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
resource "kubernetes_secret" "spinnaker_echo_custom_templates" {
  metadata {
    name = "echo-custom-templates"
    namespace = "spinnaker"
  }
  data = {
    "mytemplate" = file("${path.module}/templates/pubsub_custom_object.json")
  }
}

resource "kubernetes_config_map" "spinnaker_echo_custom_templates" {
  metadata {
    name = "echo-custom-templates"
    namespace = "spinnaker"
  }
  data = {
    "pubsub_embedded_artifact.json" = file("${path.module}/templates/pubsub_embedded_artifact.json")
    "pubsub_custom_object.json" = file("${path.module}/templates/pubsub_custom_object.json")
  }
}