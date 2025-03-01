data "fastly_services" "services" {}

output "fastly_services_all" {
  value = data.fastly_services.services
}

output "fastly_services_filtered" {
  value = one([for service in data.fastly_services.services.details : service.id if service.name == "My Test Service"])
}

output "fastly_services_version" {
  value = one([for service in data.fastly_services.services.details : service.version if service.name == "My Test Service"])
}

resource "fastly_service_vcl" "service" {
  name    = var.service_vcl.name
  comment = var.service_vcl.comment
  force_destroy  = var.service_vcl.force_destroy
  stale_if_error = var.service_vcl.stale_if_error

  domain {
    name = var.domain.name
    comment = var.domain.comment
  }

  dynamic backend {
    for_each = var.backends

    content {
      name = backend.value["name"]
      address = backend.value["address"]
      ssl_cert_hostname = backend.value["ssl_cert_hostname"]
      ssl_sni_hostname = backend.value["ssl_sni_hostname"]
      weight = backend.value["weight"]
      use_ssl = backend.value["use_ssl"]
      max_conn = backend.value["max_conn"]
      connect_timeout = backend.value["connect_timeout"]
      first_byte_timeout = backend.value["first_byte_timeout"]
      between_bytes_timeout = backend.value["between_bytes_timeout"]
      override_host = backend.value["override_host"]
      port = backend.value["port"]
    }
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
    content_types = var.gzip_content_types
    extensions = var.gzip_extensions
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

  # setup redirects
  vcl {
    name    = "homepage_redirect"
    content = file("${path.module}/vcl/homepage_redirect.vcl")
    main    = true
  }

  # cache objects for a year
  header {
    action        = "set"
    destination   = "http.surrogate-control"
    name          = "Surrogate-Control"
    type          = "cache"
    source        = "\"max-age=31557600\""
    ignore_if_set = false
    priority      = 10
  }

  # tell browser to not cache the object
  header {
    action        = "set"
    destination   = "http.cache-control"
    name          = "Cache-Control"
    type          = "cache"
    source        = "\"no-store,max-age=0\""
    ignore_if_set = false
    priority      = 10
  }
}