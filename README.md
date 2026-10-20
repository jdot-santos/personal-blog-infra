# personal-blog-infra

This Terraform module manages the Fastly infrastructure for a personal blog, including custom domains, backends, VCL logic, headers, gzip settings, and logging to Grafana Cloud.

## Overview

This repository provisions and configures a Fastly VCL service with the following features:

- **Custom domains and TLS enforcement**
- **Multiple backends with load balancing**
- **Response compression (gzip) based on cache condition**
- **Header manipulation**
- **Custom VCL inclusion**
- **Logging to Grafana Cloud via `logging_grafanacloudlogs`**

Terraform Cloud is used for remote backend and state management.

---

## Terraform Cloud

Organization: [`jsantosc_blog`](https://app.terraform.io/app/jsantosc_blog/workspaces)

Terraform Cloud holds the state, the variables, and runs every plan/apply for the Fastly service. Each workspace is tied to a git branch and manages its own Fastly service:

| Workspace | Branch | Apply |
|---|---|---|
| [`web_blog_feature`](https://app.terraform.io/app/jsantosc_blog/workspaces/web_blog_feature) | feature work | — |
| [`web_blog_dev`](https://app.terraform.io/app/jsantosc_blog/workspaces/web_blog_dev) | `dev` | auto |
| [`web_blog_staging`](https://app.terraform.io/app/jsantosc_blog/workspaces/web_blog_staging) | `staging` | auto |
| [`web_blog_production`](https://app.terraform.io/app/jsantosc_blog/workspaces/web_blog_production) | `production` | manual confirm |

Each workspace's **Variables** page holds the inputs for `variables.tf` (there are no tfvars for the root module in this repo):

- Terraform variables: `env`, `service_vcl`, `domains`, `backends`, `headers`, `vcls`, `grafana_log` (sensitive)
- Environment variable: `FASTLY_API_KEY` (sensitive)

The workspaces and their variables are themselves managed by Terraform in [`terraform_cloud_config/`](./terraform_cloud_config). Change values there, not in the UI, or the next bootstrap apply will overwrite them.

### Deploying

1. Open a PR from a feature branch into `dev`. GitHub Actions runs `terraform fmt -check` and `terraform validate`.
2. Merge. `web_blog_dev` plans and applies automatically.
3. Promote with PRs `dev` → `staging` (auto-applies) → `production` (confirm the apply in the workspace).

To check for drift without changing anything: open a workspace → **New run** → **Run type: Plan only**.

---

## Project Structure

```
.
├── main.tf                  # Main infrastructure definition (Fastly service)
├── variables.tf             # Input variable definitions
├── outputs.tf               # Outputs (optional)
├── terraform.tf             # Remote backend & cloud settings
├── vcl/                     # Custom VCL snippets
├── templates/               # Optional: template files (e.g., JSON logging format)
└── README.md                # Documentation
```

## Development & Contribution

- Format code with: `terraform fmt`
- Validate syntax: `terraform validate`
- Use `terraform plan` before committing changes

---

## TODO

- [ ] **Rotate the Fastly API key.** Generate a new token in the Fastly console, update the
      `FASTLY_API_KEY` environment variable in all four Terraform Cloud workspaces
      (`web_blog_feature`, `web_blog_dev`, `web_blog_staging`, `web_blog_production`),
      then revoke the old token. Also update any local `*.tfvars.ignore` file.

---

## License

MIT License. See [LICENSE](./LICENSE) for details.

---

## Maintainer

James Santos-Calacat  
Personal Blog Infra · [@jsantosc](https://github.com/jdot-santos)  
