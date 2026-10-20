# terraform_cloud_config

Terraform that manages the Terraform Cloud side of the blog: the [`jsantosc_blog`](https://app.terraform.io/app/jsantosc_blog/workspaces) organization, its four workspaces, and every variable inside them. The repo root then runs *inside* those workspaces to manage Fastly.

```
terraform_cloud_config/ ──writes vars──► TFC workspace ──runs──► repo root ──► Fastly service
       (your laptop)                     (one per env)                         (one per env)
```

## This folder is the source of truth

Workspace settings and variables are changed **here, never in the Terraform Cloud UI**. A UI edit gets reverted by the next apply from this folder.

| Manages | Resource |
|---|---|
| Organization | `tfe_organization.jsantosc_blog` (in `imports.tf`) |
| Workspaces `web_blog_feature`, `_dev`, `_staging`, `_production` | `tfe_workspace.workspaces` |
| Workspace variables (`env`, `service_vcl`, `domains`, `backends`, `headers`, `vcls`, `grafana_log`, `FASTLY_API_KEY`) | `tfe_variable.*` |
| GitHub OAuth client (unused, pending removal) | `tfe_oauth_client.github` |

`dev`, `staging`, and `production` connect to GitHub through the HCP Terraform GitHub App (`github_app_installation_id`). `web_blog_feature` has no VCS connection; it is CLI-driven.

## How it runs

- **Where:** your laptop only. No CI job or Terraform Cloud workspace runs it.
- **State:** local `terraform.tfstate` in this folder. Gitignored, not backed up, and contains every secret in plaintext.
- **Inputs:** `inputs.tfvars` in this folder. Gitignored, holds all secrets, not auto-loaded.
- **Auth:** `terraform login` (or `TFE_TOKEN`).

```bash
cd terraform_cloud_config
terraform init
terraform plan  -var-file=inputs.tfvars -detailed-exitcode   # exit 0 = in sync, 2 = changes/drift
terraform apply -var-file=inputs.tfvars
```

## Making a change

1. Run `terraform plan -var-file=inputs.tfvars -detailed-exitcode` **before** editing anything. It must say `No changes`. If it doesn't, someone edited the UI: fold that change into the code (or decide to revert it) first.
2. Edit the `.tf` files and/or `inputs.tfvars`.
3. Plan, read every change, apply.
4. Plan again. It must say `No changes`.

### Rotating a secret (e.g. `FASTLY_API_KEY`)

1. Create the new credential, scoped to the one environment that needs it.
2. Replace the value in `inputs.tfvars` for that environment.
3. Plan (expect one `tfe_variable` update, value shown as sensitive) and apply.
4. Prove it in the target workspace: **New run → Plan only**, expect `No changes`.
5. Revoke the old credential, then run the plan-only check again. A `401` means the workspace still has the old value.

## Don't

- Don't edit workspace settings or variables in the UI.
- Don't commit `inputs.tfvars`, `*.tfvars.ignore`, or `terraform.tfstate*`.
- Don't delete `terraform.tfstate`. Without it this folder would try to recreate the organization; recovery means importing every resource.
