# Unit tests for main.tf. Run: terraform test
# The Fastly provider is mocked, so no API key or network is needed.

mock_provider "fastly" {}

variables {
  env = "test"

  service_vcl = {
    name           = "Fastly service - TEST"
    comment        = "test"
    force_destroy  = true
    stale_if_error = false
  }

  domains = [
    { name = "www.example.com", comment = "www" },
    { name = "example.com", comment = "apex" },
  ]

  backends = [{
    name                  = "github_pages"
    address               = "jdot-santos.github.io"
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
  }]

  headers = [{
    name          = "Surrogate-Control"
    type          = "cache"
    action        = "set"
    destination   = "http.Surrogate-Control"
    source        = "\"max-age=86400\""
    ignore_if_set = false
    priority      = 10
  }]

  vcls = [{
    name      = "main"
    file_name = "main.vcl"
    main      = true
  }]

  grafana_log = {
    name     = "grafana"
    token    = "fake-token"
    url      = "https://logs.example.com"
    user     = "123"
    app_name = "blog"
  }
}

run "one_domain_block_per_input" {
  command = plan

  assert {
    condition     = toset([for d in fastly_service_vcl.service.domain : d.name]) == toset([for d in var.domains : d.name])
    error_message = "Every input domain must produce a domain block"
  }
}

run "backend_uses_tls_to_origin" {
  command = plan

  assert {
    condition     = alltrue([for b in fastly_service_vcl.service.backend : b.use_ssl && b.port == 443])
    error_message = "Backends must connect to the origin over TLS on 443"
  }
}

run "force_tls_wired_to_condition" {
  command = plan

  assert {
    condition     = one(fastly_service_vcl.service.request_setting).force_ssl && one(fastly_service_vcl.service.request_setting).request_condition == "force_https"
    error_message = "Force TLS request setting must use the force_https condition"
  }
}

run "vcl_loaded_from_file" {
  command = plan

  assert {
    condition     = one(fastly_service_vcl.service.vcl).content == file("vcl/main.vcl")
    error_message = "The main VCL must be the contents of vcl/main.vcl"
  }
}

run "logs_tagged_with_env" {
  command = plan

  assert {
    condition     = jsondecode(one(fastly_service_vcl.service.logging_grafanacloudlogs).index).env == var.env
    error_message = "Grafana log index must carry the env label"
  }
}
