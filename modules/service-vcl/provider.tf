terraform {
  required_providers {
    fastly = {
      source  = "fastly/fastly"
      version = ">= 5.15.0"
    }
  }
}

# Use this if you're not using the 'export' command
# For more info, see https://registry.terraform.io/providers/fastly/fastly/latest/docs#environment-variables
# provider "fastly" {
#   api_key = ""
# }