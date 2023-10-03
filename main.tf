terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "pod_rejection_due_to_pod_security_policy_psp_violation" {
  source    = "./modules/pod_rejection_due_to_pod_security_policy_psp_violation"

  providers = {
    shoreline = shoreline
  }
}