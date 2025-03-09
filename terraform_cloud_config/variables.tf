variable "hostname" {
  type        = string
  description = "The Terraform Cloud/Enterprise hostname to connect to"
  default     = "app.terraform.io"
}

variable "oauth_name" {
  type    = string
  default = "tdd-github"
}

variable "organization" {
  description = "Terraform Cloud organization"
  type = object({
    name  = string
    email = string
  })
}

variable "gh_pat" {
  type        = string
  description = "Github Personal Access token"
}

variable "workspaces" {
  type = list(object({
    name                  = string
    queue_all_runs        = bool
    file_triggers_enabled = bool
    auto_apply            = bool
    vcs_branch_name       = string
    use_vcs_repo          = bool
  }))
}

variable "gh_repo" {
  type = object({
    identifier     = string
    oauth_token_id = string
  })
}