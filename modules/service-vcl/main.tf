resource "fastly_service_vcl" "demo" {
  name    = "demofastly"
  comment = "Managed by Terraform"

  domain {
    name    = "jsantos-demo.global.ssl.fastly.net"
    comment = "demo"
  }

  backend {
    address = "jdot-santos.github.io"
    name    = "My blog hosted by Github Pages"

    # most of these values come default when creating the CDN service using the values above
    auto_loadbalance      = false
    ssl_cert_hostname     = "jdot-santos.github.io"
    ssl_sni_hostname      = "jdot-santos.github.io"
    weight                = 100
    use_ssl               = true
    max_conn              = 200
    connect_timeout       = 1000
    first_byte_timeout    = 15000
    between_bytes_timeout = 10000
    override_host         = "jdot-santos.github.io"
    port                  = 443
  }

  condition {
    name      = "force_https"
    type      = "REQUEST"
    priority  = 10
    statement = "req.http.X-Forwarded-Proto == \"http\""
  }

  # Request setting to force TLS
  request_setting {
    name              = "Force TLS"
    force_ssl         = true
    request_condition = "force_https"
  }

  condition {
    name      = "status_200_or_404"
    type      = "CACHE"
    priority  = 10
    statement = "beresp.status == 200 || beresp.status == 404"
  }

  gzip {
    name = "custom-compression-policy"
    content_types = [
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
    extensions = [
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
    cache_condition = "status_200_or_404"
  }

  # Header to enable HSTS
  header {
    name        = "Enable HSTS"
    action      = "set"
    destination = "http.Strict-Transport-Security"
    type        = "response"
    source      = "\"max-age=31536000; includeSubDomains; preload\""
    priority    = 10
  }
  #   vcl {
  #     name    = "my_custom_main_vcl"
  #     content = file("${path.module}/vcl/main.vcl")
  #     main    = true
  #   }

  force_destroy = true
}