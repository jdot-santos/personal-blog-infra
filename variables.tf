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

variable "domains" {
  type = list(object({
    name    = string
    comment = string
  }))
}

variable "headers" {
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

variable "tls_subscription" {
  type = object({
    id                    = string
    certificate_authority = string
    common_name           = string
  })
}