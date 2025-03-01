variable "env" {
  type        = string
  description = "The environment"
}

variable "gzip_extensions" {
  type = list(string)
}

variable "gzip_content_types" {
  type = list(string)
}

variable "domain" {
  description = "Domain configuration"
  type = object({
    name    = string
    comment = string
  })
}

variable "backends" {
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

variable "service_vcl" {
  type = object({
    name           = string
    comment        = string
    force_destroy  = bool
    stale_if_error = bool
  })
}