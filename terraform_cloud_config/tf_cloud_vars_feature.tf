###################
# FEATURE
###################

resource "tfe_variable" "env_feature" {
  key = "env"
  value = "feature"
  category = "terraform"
  description = "Used for feature development/playground"
  sensitive = false
  hcl = false
  workspace_id = tfe_workspace.web_blog_feature.id
}
resource "tfe_variable" "service_vcl_feature" {
  key = "service_vcl"
  value = jsonencode(var.var_service_vcl_feature)
  category = "terraform"
  description = "Service VCL"
  sensitive = false
  hcl = true
  workspace_id = tfe_workspace.web_blog_feature.id
}
resource "tfe_variable" "domains_feature" {
  key = "domains"
  value = jsonencode(var.var_domains_feature)
  category = "terraform"
  description = "Fastly domains"
  sensitive = false
  hcl = true
  workspace_id = tfe_workspace.web_blog_feature.id
}
resource "tfe_variable" "backends_feature" {
  key = "backends"
  value = jsonencode(var.var_backends_feature)
  category = "terraform"
  description = "Fastly VCL backends"
  sensitive = false
  hcl = true
  workspace_id = tfe_workspace.web_blog_feature.id
}
resource "tfe_variable" "headers_feature" {
  key = "headers"
  value = jsonencode(var.var_headers_feature)
  category = "terraform"
  description = "List of Fastly headers"
  sensitive = false
  hcl = true
  workspace_id = tfe_workspace.web_blog_feature.id
}
resource "tfe_variable" "vcls_feature" {
  key = "vcls"
  value = jsonencode(var.var_vcls_feature)
  category = "terraform"
  description = "List of Fastly VCLs"
  sensitive = false
  hcl = true
  workspace_id = tfe_workspace.web_blog_feature.id
}
resource "tfe_variable" "fastly_api_key_feature" {
  key = "FASTLY_API_KEY"
  value = var.var_fastly_api_key_feature
  category = "env"
  description = "Fastly API key"
  sensitive = true
  hcl = false
  workspace_id = tfe_workspace.web_blog_feature.id
}