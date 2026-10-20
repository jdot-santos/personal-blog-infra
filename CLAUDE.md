# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Terraform for a Fastly CDN (`fastly_service_vcl`) in front of a GitHub Pages blog (`jdot-santos.github.io`), logging to Grafana Cloud Loki. Two independent Terraform root modules:

- **Repo root**: the Fastly service. `main.tf` is one resource; everything (domains, backends, force-TLS, gzip, headers, VCL, logging) hangs off it.
- **`terraform_cloud_config/`**: bootstraps Terraform Cloud (org `jsantosc_blog`, GitHub OAuth client, workspaces) and writes every root-module variable into each workspace. It uses **local state** (`terraform.tfstate` in that dir, untracked).

`docs/CODEBASE-NOTES.md` has a deeper onboarding map, an end-to-end request trace, and known risks.

## Commands

No tests exist. CI (`.github/workflows/terraform.yml`, on every push) only runs these from the repo root:

```bash
terraform init
terraform fmt -check        # use -recursive locally to also cover terraform_cloud_config/
terraform validate
```

Bootstrap module (needs `TFE_TOKEN`; tfvars is local-only and holds secrets):

```bash
cd terraform_cloud_config
terraform init
terraform plan -var-file=inputs.tfvars
```

## How changes deploy

- Root-module variables have **no tfvars in the repo**. Values per environment live in `terraform_cloud_config` and are pushed into TFC workspaces as variables (`FASTLY_API_KEY` as an env var).
- `terraform_cloud_config/` is the source of truth for workspace settings and variables; never change them in the TFC UI. Before applying it, `terraform plan -var-file=inputs.tfvars -detailed-exitcode` must show `No changes` (exit 0). See `terraform_cloud_config/README.md`.
- Workspaces: `web_blog_dev`, `web_blog_staging`, `web_blog_production` are VCS-bound to the matching git branch; `web_blog_feature` is CLI-driven (see README for Remote vs Local execution).
- Promotion is by PR: feature branch → `dev` → `staging` → `production` → `main`. `dev` and `staging` auto-apply; production applies manually.
- **Every new PR targets `dev`**: always `gh pr create --base dev` (GitHub's default base is `main`). Never open a feature PR against `main`, `staging`, or `production`; those only receive promotion PRs from the previous branch.
- Local root-module runs use the gitignored `backend_local.tf`, a `cloud {}` block pointed at `web_blog_feature`. Without it, `terraform init` silently uses local state.

## Editing VCL (`vcl/main.vcl`)

- Loaded via `file()` in `main.tf`, so `terraform validate` does **not** check VCL syntax. Errors surface only when Fastly compiles it at apply time, and dev/staging auto-apply.
- Keep the `#FASTLY <sub>` macros in each subroutine.
- Edge logic pattern: `vcl_recv` matches a request (often via a `table`) and raises `error <custom code> "<label>"`; `vcl_error` matches on `obj.status` + `obj.response` and builds the response. Existing codes: 600 add-www redirect, 620 `solution_redirects` table redirect, 621 `paths_to_block` → 403. New redirects usually mean adding a row to `solution_redirects`.
- Caching is driven by the `headers` variable (Surrogate-Control for the edge, Cache-Control `no-store` for browsers) plus the default 3600s TTL in `vcl_fetch`.

## Conventions

- Update `version_comment` in `main.tf` to describe the change. It becomes the Fastly service version note, the only rollback map.
- Add a `CHANGELOG.md` entry per feature.
- Secrets live in gitignored tfvars: `terraform_cloud_config/inputs.tfvars` (all environments) and root `inputs.tfvars` (FEATURE, for Local execution mode). Never stage them.
