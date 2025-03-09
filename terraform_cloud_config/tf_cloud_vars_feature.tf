locals {
  env_to_workspace = {
    dev      = tfe_workspace.web_blog_dev
    feature  = tfe_workspace.web_blog_feature
    staging  = tfe_workspace.web_blog_staging
    prod     = tfe_workspace.web_blog_prod
  }
}

resource "tfe_variable" "env_vars" {
  for_each = var.environments
  key          = "env"
  value        = each.value.env
  category     = "terraform"
  description  = "Environment variable for ${each.key}"
  sensitive    = false
  hcl          = false
  workspace_id = local.env_to_workspace[each.key].id
}

resource "tfe_variable" "service_vcl_vars" {
  for_each = var.environments
  key          = "service_vcl"
  value        = jsonencode(each.value.service_vcl)
  category     = "terraform"
  description  = "Service VCL for ${each.key}"
  sensitive    = false
  hcl          = true
  workspace_id = local.env_to_workspace[each.key].id
}

resource "tfe_variable" "domains_vars" {
  for_each = var.environments

  key          = "domains"
  value        = jsonencode(each.value.domains)
  category     = "terraform"
  description  = "Domains for ${each.key}"
  sensitive    = false
  hcl          = true
  workspace_id = local.env_to_workspace[each.key].id
}

resource "tfe_variable" "backends_vars" {
  for_each = var.environments

  key          = "backends"
  value        = jsonencode(each.value.backends)
  category     = "terraform"
  description  = "Backends for ${each.key}"
  sensitive    = false
  hcl          = true
  workspace_id = local.env_to_workspace[each.key].id
}

resource "tfe_variable" "headers_vars" {
  for_each = var.environments

  key          = "headers"
  value        = jsonencode(each.value.headers)
  category     = "terraform"
  description  = "Headers for ${each.key}"
  sensitive    = false
  hcl          = true
  workspace_id = local.env_to_workspace[each.key].id
}

resource "tfe_variable" "vcls_vars" {
  for_each = var.environments

  key          = "vcls"
  value        = jsonencode(each.value.vcls)
  category     = "terraform"
  description  = "VCLs for ${each.key}"
  sensitive    = false
  hcl          = true
  workspace_id = local.env_to_workspace[each.key].id
}

resource "tfe_variable" "fastly_api_key_vars" {
  for_each = var.environments

  key          = "FASTLY_API_KEY"
  value        = each.value.fastly_api_key
  category     = "env"
  description  = "Fastly API key for ${each.key}"
  sensitive    = true
  hcl          = false
  workspace_id = local.env_to_workspace[each.key].id
}