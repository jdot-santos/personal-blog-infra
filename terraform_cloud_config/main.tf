provider "tfe" {
  # Configuration options
  hostname = var.hostname
}

resource "tfe_oauth_client" "github" {
  name             = var.oauth_name
  organization     = tfe_organization.jsantosc_blog.name
  api_url          = "https://api.github.com"
  http_url         = "https://github.com"
  oauth_token      = var.gh_pat
  service_provider = "github"
}