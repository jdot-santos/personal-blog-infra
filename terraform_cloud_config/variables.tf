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

variable "var_service_vcl_feature" {
  type = object({
    name = string
    comment = string
    force_destroy = bool
    stale_if_error = bool
  })
}

variable "var_domains_feature" {
  type = list(object({
    name    = string
    comment = string
  }))
}

variable "var_backends_feature" {
  type = list(object({
    name                  = string
    address               = string
    auto_loadbalance      = bool
    ssl_cert_hostname     = string
    ssl_sni_hostname      = string
    weight                = number
    use_ssl               = bool
    max_conn              = number
    connect_timeout       = number
    first_byte_timeout    = number
    between_bytes_timeout = number
    override_host         = string
    port                  = number
  }))
}

variable "var_headers_feature" {
  type = list(object({
    name          = string
    type          = string
    action        = string
    destination   = string
    source        = string
    ignore_if_set = bool
    priority      = number
  }))
}

variable "var_vcls_feature" {
  type = list(object({
    name      = string
    file_name = string
    main      = bool
  }))
}

variable "var_fastly_api_key_feature" {
  type = string
  description = "Fastly API key"
}