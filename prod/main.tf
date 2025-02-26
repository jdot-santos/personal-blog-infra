module "vcl" {
  source             = "../modules/service-vcl"
  gzip_extensions    = var.gzip_extensions
  gzip_content_types = var.gzip_content_types
  domain             = var.domain
  backends           = var.backends
  service_vcl = var.service_vcl
}