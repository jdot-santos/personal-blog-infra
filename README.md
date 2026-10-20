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
| [`web_blog_feature`](https://app.terraform.io/app/jsantosc_blog/workspaces/web_blog_feature) | none (CLI-driven) | manual confirm |
| [`web_blog_dev`](https://app.terraform.io/app/jsantosc_blog/workspaces/web_blog_dev) | `dev` | auto |
| [`web_blog_staging`](https://app.terraform.io/app/jsantosc_blog/workspaces/web_blog_staging) | `staging` | auto |
| [`web_blog_production`](https://app.terraform.io/app/jsantosc_blog/workspaces/web_blog_production) | `production` | manual confirm |

Each workspace's **Variables** page holds the inputs for `variables.tf` (there are no tfvars for the root module in this repo):

- Terraform variables: `env`, `service_vcl`, `domains`, `backends`, `headers`, `vcls`, `grafana_log` (sensitive)
- Environment variable: `FASTLY_API_KEY` (sensitive)

The workspaces and their variables are themselves managed by Terraform in [`terraform_cloud_config/`](./terraform_cloud_config). Change values there, not in the UI, or the next bootstrap apply will overwrite them.

### Testing changes on the FEATURE service

`web_blog_feature` is for trying changes from your machine before opening a PR. It manages its own Fastly service, `Fastly service - FEATURE`, served at `https://jsantosc-feature.global.ssl.fastly.net`. Its state lives in Terraform Cloud either way; the workspace's **Execution Mode** (Settings → General) decides where Terraform runs.

**Remote (default)**: Terraform runs in Terraform Cloud using the workspace's variables.

```bash
terraform login   # once
terraform init
terraform plan    # uploads your local code, runs it remotely
terraform apply   # same, then waits for you to confirm
```

`.terraformignore` keeps `terraform_cloud_config/` and `*.tfvars` out of the upload.

**Local**: Terraform runs on your machine. Set Execution Mode to **Local** first.

```bash
export FASTLY_API_KEY=<feature key>
terraform plan -var-file=inputs.tfvars
terraform apply -var-file=inputs.tfvars
```

`inputs.tfvars` (repo root, gitignored) mirrors the `web_blog_feature` values in `terraform_cloud_config/inputs.tfvars`. Update both when a feature value changes.

Notes:

- `terraform validate` does not check VCL. Fastly only compiles `vcl/main.vcl` on apply, so apply to FEATURE to prove a VCL change, then check it with `curl -I https://jsantosc-feature.global.ssl.fastly.net/<path>`.
- A run started from the Terraform Cloud UI reuses the last code uploaded by a CLI `apply`, not by a CLI `plan`. Run `terraform apply` from the CLI to refresh it before using UI runs.
- Switch Execution Mode back to **Remote** when you're done.

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

## License

MIT License. See [LICENSE](./LICENSE) for details.

---

## Maintainer

James Santos-Calacat  
Personal Blog Infra · [@jsantosc](https://github.com/jdot-santos)  
