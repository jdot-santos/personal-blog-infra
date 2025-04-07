provider "tfe" {
  # Configuration options
  hostname = var.hostname
}

locals {
  workspace_map = { for ws in var.workspaces : ws.name => ws }
}

resource "tfe_oauth_client" "github" {
  name             = var.oauth_name
  organization     = tfe_organization.jsantosc_blog.name
  api_url          = "https://api.github.com"
  http_url         = "https://github.com"
  oauth_token      = var.gh_pat
  service_provider = "github"
}

resource "tfe_workspace" "workspaces" {
  for_each = local.workspace_map

  name                  = each.key
  organization          = tfe_organization.jsantosc_blog.name
  queue_all_runs        = each.value.queue_all_runs
  file_triggers_enabled = each.value.file_triggers_enabled
  auto_apply            = each.value.auto_apply

  dynamic "vcs_repo" {
    for_each = each.value.use_vcs_repo ? [1] : []
    content {
      branch         = each.value.vcs_branch_name
      identifier     = var.gh_repo.identifier
      oauth_token_id = var.gh_repo.oauth_token_id
    }
  }
}

resource "tfe_variable" "env_vars" {
  for_each     = var.environments
  key          = "env"
  value        = each.value.env
  category     = "terraform"
  description  = "Environment variable for ${each.key}"
  sensitive    = false
  hcl          = false
  workspace_id = tfe_workspace.workspaces[each.key].id
}

resource "tfe_variable" "service_vcl_vars" {
  for_each     = var.environments
  key          = "service_vcl"
  value        = jsonencode(each.value.service_vcl)
  category     = "terraform"
  description  = "Service VCL for ${each.key}"
  sensitive    = false
  hcl          = true
  workspace_id = tfe_workspace.workspaces[each.key].id
}

resource "tfe_variable" "domains_vars" {
  for_each = var.environments

  key          = "domains"
  value        = jsonencode(each.value.domains)
  category     = "terraform"
  description  = "Domains for ${each.key}"
  sensitive    = false
  hcl          = true
  workspace_id = tfe_workspace.workspaces[each.key].id
}

resource "tfe_variable" "backends_vars" {
  for_each = var.environments

  key          = "backends"
  value        = jsonencode(each.value.backends)
  category     = "terraform"
  description  = "Backends for ${each.key}"
  sensitive    = false
  hcl          = true
  workspace_id = tfe_workspace.workspaces[each.key].id
}

resource "tfe_variable" "headers_vars" {
  for_each = var.environments

  key          = "headers"
  value        = jsonencode(each.value.headers)
  category     = "terraform"
  description  = "Headers for ${each.key}"
  sensitive    = false
  hcl          = true
  workspace_id = tfe_workspace.workspaces[each.key].id
}

resource "tfe_variable" "vcls_vars" {
  for_each = var.environments

  key          = "vcls"
  value        = jsonencode(each.value.vcls)
  category     = "terraform"
  description  = "VCLs for ${each.key}"
  sensitive    = false
  hcl          = true
  workspace_id = tfe_workspace.workspaces[each.key].id
}

resource "tfe_variable" "fastly_api_key_vars" {
  for_each = var.environments

  key          = "FASTLY_API_KEY"
  value        = each.value.fastly_api_key
  category     = "env"
  description  = "Fastly API key for ${each.key}"
  sensitive    = true
  hcl          = false
  workspace_id = tfe_workspace.workspaces[each.key].id
}

resource "tfe_variable" "grafana_log_vars" {
  for_each = var.environments

  key          = "grafana_log"
  value        = jsonencode(each.value.grafana_log)
  category     = "terraform"
  description  = "Grafana Log for ${each.key}"
  sensitive    = true
  hcl          = true
  workspace_id = tfe_workspace.workspaces[each.key].id
}