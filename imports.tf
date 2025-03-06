# import {
#   to = fastly_tls_subscription.jsantosc
#   id = var.tls_subscription["id"]
# }
#
# resource "fastly_tls_subscription" "jsantosc" {
#   domains = [for domain in fastly_service_vcl.service.domain : domain.name]
#   certificate_authority = var.tls_subscription["certificate_authority"]
#   common_name = var.tls_subscription["common_name"]
# }