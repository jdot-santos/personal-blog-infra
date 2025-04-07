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

variable "grafana_log_format" {
  type    = string
  default = <<-EOT
    {
      "client_ip": "%%{req.http.Fastly-Client-IP}V",
      "continent_code": "%%{client.geo.continent_code}V",
      "country_code": "%%{client.geo.country_code}V",
      "elapsed_ms": "%%{time.elapsed.msec}V",
      "fastly_server": "%%{json.escape(server.identity)}V",
      "fastly_is_edge": %%{if(fastly.ff.visits_this_service == 0, "true", "false")}V,
      "geo_city": "%%{client.geo.city}V",
      "geo_country": "%%{client.geo.country_name}V",
      "host": "%%{if(req.http.Fastly-Orig-Host, req.http.Fastly-Orig-Host, req.http.Host)}V",
      "ja3": "%%{tls.client.ja3_md5}V",
      "ja4": "%%{tls.client.ja4}V",
      "pop": "%%{server.datacenter}V",
      "region": "%%{client.geo.region}V",
      "req_method": "%%{json.escape(req.method)}V",
      "req_num_headers": "%%{std.count(req.headers)}V",
      "req_protocol": "%%{json.escape(req.proto)}V",
      "req_referer": "%%{json.escape(req.http.referer)}V",
      "req_size_headers": "%%{req.header_bytes_read}V",
      "req_user_agent": "%%{json.escape(req.http.User-Agent)}V",
      "resp_body_bytes_written": "%%{resp.body_bytes_written}V",
      "resp_body_size": %%{resp.body_bytes_written}V,
      "resp_content_type": "%%{resp.http.content-type}V",
      "resp_header_bytes_written": "%%{resp.header_bytes_written}V",
      "resp_reason": %%{if(resp.response, "%22"+json.escape(resp.response)+"%22", "null")}V,
      "resp_state": "%%{json.escape(fastly_info.state)}V",
      "resp_status": %%{resp.status}V,
      "server_region": "%%{server.region}V",
      "timestamp": "%%{strftime(\{"%Y-%m-%dT%H:%M:%S"\}, time.start)}V",
      "url": "%%{json.escape(req.url)}V",
      "workspace_size_free": "%%{workspace.bytes_free}V"
    }
  EOT
}

variable "grafana_log" {
  type = object({
    name     = string
    token    = string
    url      = string
    user     = string
    app_name = string
  })
}