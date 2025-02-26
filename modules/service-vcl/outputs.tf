output "active" {
  value = fastly_service_vcl.service.active_version
}