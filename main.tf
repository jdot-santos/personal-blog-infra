resource "fastly_service_vcl" "service" {
  name           = var.service_vcl.name
  comment        = var.service_vcl.comment
  force_destroy  = var.service_vcl.force_destroy
  stale_if_error = var.service_vcl.stale_if_error

  dynamic "domain" {
    for_each = var.domains

    content {
      name    = domain.value["name"]
      comment = domain.value["comment"]
    }
  }

  dynamic "backend" {
    for_each = var.backends

    content {
      name                  = backend.value.name
      address               = backend.value.address
      ssl_cert_hostname     = backend.value.auto_loadbalance
      ssl_sni_hostname      = backend.value.ssl_sni_hostname
      weight                = backend.value.weight
      use_ssl               = backend.value.use_ssl
      max_conn              = backend.value.max_conn
      connect_timeout       = backend.value.connect_timeout
      first_byte_timeout    = backend.value.first_byte_timeout
      between_bytes_timeout = backend.value.between_bytes_timeout
      override_host         = backend.value.override_host
      port                  = backend.value.port
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
    name            = "custom-compression-policy"
    content_types   = var.gzip_content_types
    extensions      = var.gzip_extensions
    cache_condition = "status_200_or_404"
  }

  dynamic "header" {
    for_each = var.headers
    content {
      name          = header.value.name
      type          = header.value.type
      action        = header.value.action
      destination   = header.value.destination
      source        = header.value.source
      ignore_if_set = header.value.ignore_if_set
      priority      = header.value.priority
    }
  }

  # setup redirects
  vcl {
    name    = "homepage_redirect"
    content = file("${path.module}/vcl/homepage_redirect.vcl")
    main    = true
  }

  # add www to apex and subdomains
  vcl {
    name    = "add_www_to_apex_subdomains"
    content = file("${path.module}/vcl/add_www_to_apex_subdomains.vcl")
  }
}

data "fastly_services" "services" {}