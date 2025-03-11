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