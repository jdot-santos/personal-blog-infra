variable "env" {
  type        = string
  description = "The environment"
}

variable "gzip_extensions" {
  type = list(string)
  default = [
    "css",
    "js",
    "html",
    "eot",
    "ico",
    "otf",
    "ttf",
    "json",
    "svg"
  ]
}

variable "gzip_content_types" {
  type = list(string)
  default = [
    "text/html",
    "application/x-javascript",
    "text/css",
    "application/javascript",
    "text/javascript",
    "application/json",
    "application/vnd.ms-fontobject",
    "application/x-font-opentype",
    "application/x-font-truetype",
    "application/x-font-ttf",
    "application/xml",
    "font/eot",
    "font/opentype",
    "font/otf",
    "image/svg+xml",
    "image/vnd.microsoft.icon",
    "text/plain",
    "text/xml"
  ]
}

variable "domains" {
  type = list(object({
    name    = string
    comment = string
  }))
  description = "List of domains"
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

variable "vcls" {
  type = list(object({
    name      = string
    file_name = string
    main      = bool
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

# variable "tls_subscription" {
#   type = object({
#     id                    = string
#     certificate_authority = string
#     common_name           = string
#   })
# }
