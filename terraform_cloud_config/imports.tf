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