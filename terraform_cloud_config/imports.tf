locals {
  workspace_names   = var.workspaces[*].name
  feature_index     = index(local.workspace_names, "web-blog-feature")
  dev_index         = index(local.workspace_names, "web-blog-dev")
  staging_index     = index(local.workspace_names, "web-blog-staging")
  prod_index        = index(local.workspace_names, "web-blog-production")
  feature_workspace = var.workspaces[local.feature_index]
  dev_workspace     = var.workspaces[local.dev_index]
  staging_workspace = var.workspaces[local.staging_index]
  prod_workspace    = var.workspaces[local.prod_index]

  workspace_map = { for ws in var.workspaces : ws.name => ws }
}

resource "tfe_organization" "jsantosc_blog" {
  aggregated_commit_status_enabled                        = true
  allow_force_delete_workspaces                           = false
  assessments_enforced                                    = false
  collaborator_auth_policy                                = "password"
  cost_estimation_enabled                                 = false
  email                                                   = var.organization.email
  name                                                    = var.organization.name
  owners_team_saml_role_id                                = null
  send_passing_statuses_for_untriggered_speculative_plans = false
  session_remember_minutes                                = 0
  session_timeout_minutes                                 = 0
  speculative_plan_management_enabled                     = true
}

resource "tfe_workspace" "web_blog_feature" {
  name                  = local.feature_workspace.name
  organization          = tfe_organization.jsantosc_blog.name
  queue_all_runs        = local.feature_workspace.queue_all_runs
  file_triggers_enabled = local.feature_workspace.file_triggers_enabled
  auto_apply            = local.feature_workspace.auto_apply
}

resource "tfe_workspace" "web_blog_dev" {
  name                  = local.dev_workspace.name
  organization          = tfe_organization.jsantosc_blog.name
  queue_all_runs        = local.dev_workspace.queue_all_runs
  file_triggers_enabled = local.dev_workspace.file_triggers_enabled
  vcs_repo {
    branch         = local.dev_workspace.vcs_branch_name
    identifier     = var.gh_repo.identifier
    oauth_token_id = var.gh_repo.oauth_token_id
  }
}

resource "tfe_workspace" "web_blog_staging" {
  name                  = local.staging_workspace.name
  organization          = tfe_organization.jsantosc_blog.name
  queue_all_runs        = local.staging_workspace.queue_all_runs
  file_triggers_enabled = local.staging_workspace.file_triggers_enabled
  auto_apply            = local.staging_workspace.auto_apply
  vcs_repo {
    branch         = local.staging_workspace.vcs_branch_name
    identifier     = var.gh_repo.identifier
    oauth_token_id = var.gh_repo.oauth_token_id
  }
}

resource "tfe_workspace" "web_blog_prod" {
  name                  = local.prod_workspace.name
  organization          = tfe_organization.jsantosc_blog.name
  queue_all_runs        = local.prod_workspace.queue_all_runs
  file_triggers_enabled = local.prod_workspace.file_triggers_enabled
  vcs_repo {
    branch         = local.prod_workspace.vcs_branch_name
    identifier     = var.gh_repo.identifier
    oauth_token_id = var.gh_repo.oauth_token_id
  }
}


# IF I were to create these workspaces from scratch
# resource "tfe_workspace" "workspace" {
#   for_each = local.workspace_map
#
#   name                  = each.key
#   organization          = tfe_organization.jsantosc_blog.name
#   queue_all_runs        = each.value.queue_all_runs
#   file_triggers_enabled = each.value.file_triggers_enabled
#   auto_apply            = each.value.auto_apply
#
#   dynamic "vcs_repo" {
#     for_each = each.value.use_vcs_repo ? [1] : []
#     content {
#       branch         = each.value.vcs_branch_name
#       identifier     = var.gh_repo.identifier
#       oauth_token_id = var.gh_repo.oauth_token_id
#     }
#   }
# }