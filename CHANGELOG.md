# Changelog

All notable changes to AKIBA across the formative and summative phases.

## Summative — Jul 2026

DevSecOps close-out: infra, config management, security gates, and deploy on `main`.

### Added
- AWS Terraform under `terraform/` (VPC, bastion, private app VM, RDS, ECR)
- NAT so the private app VM can pull images from ECR
- Ansible playbooks for Docker install (`playbook.yml`) and image deploy (`deploy.yml`)
- Security workflow: npm audit, Trivy on the image, Checkov on Terraform/Actions
- `cd.yml` — on push to `main`: lint/test/audit/Trivy → push ECR → Ansible `docker-compose up -d`
- nginx on the bastion as the public front door to the app

### Changed
- Production runs the root Dockerfile image from ECR (`docker-compose.prod.yml`), not the local build-style compose

## Formative 2 — Jul 2026

CI and scanning landed while the app was still mostly local/Docker Compose.

### Added
- `ci.yml` — lint, tests, Docker build on feature branches / PRs to `main`
- `security-scan.yml` + notes in `SECURITY.md`
- Branch protection / CODEOWNERS so main only moves through review
- Ansible scaffolding and inventory wired to the bastion + app IPs

### Fixed
- Runtime image: OS packages patched, npm CLI dropped from the final stage (Trivy findings)

## Formative 1 — Jun 2026

First working slice of the product and local tooling.

### Added
- Monorepo: Express API (`server/`) + React/Vite client (`client/`) + Postgres
- Root production `Dockerfile` (API serves the built SPA)
- `docker-compose.yml` for local postgres / server / client
- README, QUICKSTART, API.md, CONTRIBUTING

### Notes
- Early experiments used a Strettch Cloud VM via Terraform; that path was replaced by the AWS setup in the summative work
