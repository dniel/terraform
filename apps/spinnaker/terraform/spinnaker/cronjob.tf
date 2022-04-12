#####################################################################
# Create Cleanup cronjob to periodically remove finished pipeline jobs.
#
# To avoid pods and jobs just making a mess hanging around indefinitely run
# a cleanup cronjob with its own service account that just has access to
# delete jobs in pipeline namespace where spinnaker creates terraform jobs
# from Spinnaker Pipelines as a Custom Stage.
#
# Found on stackoverflow
# https://stackoverflow.com/questions/41385403/how-to-automatically-remove-completed-kubernetes-jobs-created-by-a-cronjob
####################################################################

resource "kubernetes_service_account" "pipeline_cleanup_sa" {
  metadata {
    name = local.service_account_name
    namespace = local.pipeline_namespace
  }
}

resource "kubernetes_role" "pipeline_jobs_cleaner_role" {
  metadata {

    name = "pipeline-jobs-cleaner-role"
    namespace = local.pipeline_namespace
  }
  rule {
    api_groups = [""]
    resources = ["jobs"]
    verbs = ["list","delete"]
  }
}

resource "kubernetes_role_binding" "pipeline_jobs_cleaner_rolebinding" {
  metadata {
    name = "pipeline-jobs-cleaner-rolebinding"
    namespace = local.pipeline_namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "Role"
    name = "pipeline-jobs-cleaner-role"
  }
  subject {
    kind = "ServiceAccount"
    name = local.service_account_name
    namespace = local.pipeline_namespace
  }
}

resource "kubernetes_cron_job" "completed_jobs_cleanup" {
  metadata {
    name = "completed-jobs-cleanup"
    namespace = local.pipeline_namespace
  }
  spec {
    schedule                      = local.cleanup_cronjob_schedule
    job_template {
      metadata {}
      spec {
        template {
          metadata {}
          spec {
            service_account_name = local.service_account_name
            restart_policy = "Never"
            container {
              name    = "kubectl"
              image   = "bitnami/kubectl:latest"
              command = ["sh", "-c", "kubectl delete jobs --field-selector status.successful=1"]
            }
          }
        }
      }
    }
  }
}