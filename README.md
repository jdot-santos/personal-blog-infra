# personal-blog-infra

This Terraform module manages the Fastly infrastructure for a personal blog, including custom domains, backends, VCL logic, headers, gzip settings, and logging to Grafana Cloud.

## 🚀 Overview

This repository provisions and configures a Fastly VCL service with the following features:

- **Custom domains and TLS enforcement**
- **Multiple backends with load balancing**
- **Response compression (gzip) based on cache condition**
- **Header manipulation**
- **Custom VCL inclusion**
- **Logging to Grafana Cloud via `logging_grafanacloudlogs`**

Terraform Cloud is used for remote backend and state management.

---

## 🧱 Project Structure

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

## 🛠️ Development & Contribution

- Format code with: `terraform fmt`
- Validate syntax: `terraform validate`
- Use `terraform plan` before committing changes

---

## 🧾 License

MIT License. See [LICENSE](./LICENSE) for details.

---

## 🙋‍♂️ Maintainer

James Santos-Calacat  
Personal Blog Infra · [@jsantosc](https://github.com/jdot-santos)  
