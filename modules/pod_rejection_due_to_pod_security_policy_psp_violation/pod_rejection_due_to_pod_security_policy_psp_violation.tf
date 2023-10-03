resource "shoreline_notebook" "pod_rejection_due_to_pod_security_policy_psp_violation" {
  name       = "pod_rejection_due_to_pod_security_policy_psp_violation"
  data       = file("${path.module}/data/pod_rejection_due_to_pod_security_policy_psp_violation.json")
  depends_on = [shoreline_action.invoke_get_pod_privilege]
}

resource "shoreline_file" "get_pod_privilege" {
  name             = "get_pod_privilege"
  input_file       = "${path.module}/data/get_pod_privilege.sh"
  md5              = filemd5("${path.module}/data/get_pod_privilege.sh")
  description      = "Check if the pod has any privileged containers running. If yes, remove the privilege from the container, and try to deploy the pod again."
  destination_path = "/agent/scripts/get_pod_privilege.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_get_pod_privilege" {
  name        = "invoke_get_pod_privilege"
  description = "Check if the pod has any privileged containers running. If yes, remove the privilege from the container, and try to deploy the pod again."
  command     = "`chmod +x /agent/scripts/get_pod_privilege.sh && /agent/scripts/get_pod_privilege.sh`"
  params      = ["POD_NAME","CONTAINER_NAME"]
  file_deps   = ["get_pod_privilege"]
  enabled     = true
  depends_on  = [shoreline_file.get_pod_privilege]
}

