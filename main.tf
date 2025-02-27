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