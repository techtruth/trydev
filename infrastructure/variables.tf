variable "deployment_tag" {
  description = "How infrastrucure assets will be tagged"
  default     = "dev"
}

variable "domain_name" {
  description = "Domain the webapp will be provisioned for"
  default     = "trydev.jamescroney.com"
}

variable "github_pat" {
  description = "Github Personal Access Token for github authentication"
  default     = "none"
}
variable "github_repo" {
  description = "Github repo to publish deployment secrets from provisioning"
  default     = "trydev"
}
