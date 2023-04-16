variable "deployment_tag" {
  description = "How infrastrucure assets will be tagged"
  default     = "dev"
}

variable "domain_name" {
  description = "Domain the webapp will be provisioned for"
  default     = "dev.mowmatch.com"
}

variable "hosted_zone" {
  description = "Hosted zone of the root domain"
  default     = "Z08999851C5G4NE7BJL3G"
}

variable "github_pat" {
  description = "Github Personal Access Token for github authentication"
  default     = "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"
}
variable "github_repo" {
  description = "Github repo to publish deployment secrets from provisioning"
  default     = "trydev"
}
