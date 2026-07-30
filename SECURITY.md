# AKIBA Security Documentation

This document describes the security scanning workflow implemented for AKIBA, the vulnerabilities identified during implementation, and the remediation actions taken. It is kept in sync with the CI configuration in [`.github/workflows/security-scan.yml`](.github/workflows/security-scan.yml).

**Last updated:** 2026-07-30  
**Related PRs:** [#35 – feat/security-scanning](https://github.com/dushimsam/akiba/pull/35), feat/iac-scanning ([#40](https://github.com/dushimsam/akiba/issues/40))

---

## Overview

AKIBA is a mobile money transaction platform. Because it handles financial data, dependency and container security are checked automatically in CI before changes reach `main`.

The project uses two complementary scanners:

| Tool | Scope | Purpose |
|------|-------|---------|
| **npm audit** | Node.js dependencies (`package-lock.json`) | Detects known CVEs in npm packages used by the app |
| **Trivy** | Docker container image | Scans OS packages and application dependencies baked into the production image |
| **Checkov** | Terraform + GitHub Actions workflows | Detects IaC misconfigurations and CI pipeline hardening issues |

These scans run alongside the main CI pipeline ([`.github/workflows/ci.yml`](.github/workflows/ci.yml)), which handles linting, tests, and Docker builds on feature branches.

---

## Security Scanning Workflow

### When scans run

The **Security Scan** workflow is defined in [`.github/workflows/security-scan.yml`](.github/workflows/security-scan.yml) and triggers on:

- **Push** to `main`
- **Pull requests** targeting `main`

This is separate from the **CI/CD** workflow, which runs on pushes to non-`main` branches and on pull requests to `main`.

```text
Pull request opened/updated
        │
        ├─► CI/CD workflow (ci.yml)
        │     • lint
        │     • tests
        │     • Docker build (smoke)
        │
        └─► Security Scan workflow (security-scan.yml)
              ├─► dependency-scan  (npm audit)
              ├─► container-scan     (Docker build + Trivy)
              └─► iac-scan           (Checkov)
```

Both security jobs run in parallel on `ubuntu-latest`.

### Job 1: `dependency-scan`

| Step | Command | Blocks merge? |
|------|---------|---------------|
| Install dependencies | `npm install` | Yes (on failure) |
| Audit production dependencies | `npm audit --omit=dev --audit-level=high` | **Yes** — fails on HIGH or CRITICAL production vulnerabilities |
| Audit all dependencies (informational) | `npm audit` | No — `continue-on-error: true` |

Production dependencies are the packages shipped in the runtime server image (`server/package.json`). Dev-only tooling (Vite, ESLint, Jest, etc.) is excluded from the blocking audit.

### Job 2: `container-scan`

| Step | Action | Blocks merge? |
|------|--------|---------------|
| Build production image | `docker build -t akiba-app:$SHA .` | Yes (on failure) |
| Scan with Trivy | `aquasecurity/trivy-action@v0.36.0` | **Yes** — fails on HIGH or CRITICAL findings |

Trivy configuration:

- **Severity filter:** `HIGH,CRITICAL`
- **Ignore unfixed:** `true` (only report vulnerabilities with available patches)
- **Exit code:** `1` (workflow fails when findings are present)

The image scanned is the multi-stage production Dockerfile at the repository root, which builds the React client and serves it from the Express server.

### Job 3: `iac-scan`

| Step | Command | Blocks merge? |
|------|---------|---------------|
| Scan IaC with Checkov | `checkov -d . --framework terraform github_actions --quiet --compact` | **Yes** — fails on any failed policy check |

Checkov scans the Terraform configuration (`main.tf`, `variables.tf`) and the GitHub Actions workflows. Severity-based filtering requires a paid platform key, so the gate is stricter than the ticket minimum: any failed check blocks the merge. tfsec was evaluated first but has no rules matching this Terraform setup (a custom API provisioner rather than cloud provider resources), so Checkov was chosen.

---

## Findings Summary

### Remediated findings

| ID | Component | Severity | Scanner | Status |
|----|-----------|----------|---------|--------|
| CVE-2026-12590 / [GHSA-v422-hmwv-36x6](https://github.com/advisories/GHSA-v422-hmwv-36x6) | `body-parser` 1.20.5 | High | npm audit | **Fixed** → 1.20.6 |
| CVE-2026-13149 / [GHSA-3jxr-9vmj-r5cp](https://github.com/advisories/GHSA-3jxr-9vmj-r5cp) | `brace-expansion` 1.1.15 | High | npm audit | **Fixed** → 1.1.16 |
| Alpine OS packages (unpatched CVEs in base image) | `node:20-alpine` runtime layer | High / Critical | Trivy | **Fixed** → `apk upgrade --no-cache` |
| npm CLI in production image | `node:20-alpine` runtime layer | High | Trivy | **Fixed** → npm binaries removed after install |
| [CKV2_GHA_1](https://www.checkov.io/5.Policy%20Index/github_actions.html) — workflows run with default write token | `ci.yml`, `security-scan.yml` | Medium | Checkov | **Fixed** → top-level `permissions: contents: read` added to both workflows |

### Production dependency scan (current status)

As of the last local verification on 2026-07-21:

```bash
npm audit --omit=dev --audit-level=high
# found 0 vulnerabilities
```

**Result:** Production dependency scans complete successfully with no HIGH or CRITICAL findings.

### Container scan (current status)

After Dockerfile hardening (Alpine package upgrades and removal of the npm CLI from the runtime image), Trivy container scans pass with no HIGH or CRITICAL findings that have available fixes.

---

## Remediation Details

### 1. `body-parser` denial-of-service vulnerability (CVE-2026-12590)

**Finding:** Versions prior to 1.20.6 silently disabled request body size limits when an invalid `limit` option was configured, allowing arbitrarily large payloads and potential denial of service.

**Impact:** Production dependency — used directly by the Express server for JSON and URL-encoded body parsing.

**Remediation:**
- Upgraded `body-parser` from `1.20.5` to `1.20.6` in `package-lock.json`
- Commit: `d4d3334` — *fix: patch high severity vulnerabilities in body-parser and brace-expansion*

**Verification:** `npm audit --omit=dev --audit-level=high` reports 0 vulnerabilities.

### 2. `brace-expansion` denial-of-service vulnerability (CVE-2026-13149)

**Finding:** `brace-expansion` versions prior to 1.1.16 exhibited exponential-time behavior when expanding consecutive non-expanding `{}` groups, allowing a tiny input to hang the Node.js event loop.

**Impact:** Dev dependency only (transitive dependency of test/lint tooling). Not included in the production Docker image.

**Remediation:**
- Upgraded `brace-expansion` from `1.1.15` to `1.1.16` in `package-lock.json`
- Commit: `d4d3334` — *fix: patch high severity vulnerabilities in body-parser and brace-expansion*

**Verification:** Resolved in the full dependency tree; no longer reported by `npm audit`.

### 3. Container image OS vulnerabilities (Trivy)

**Finding:** Trivy reported HIGH/CRITICAL vulnerabilities in Alpine Linux packages bundled with the `node:20-alpine` base image.

**Impact:** Production container — exploitable if an attacker can reach the running service and chain with other flaws.

**Remediation:**
- Added `apk upgrade --no-cache` to the runtime stage of the Dockerfile to apply available Alpine security patches at build time
- Commit: `1d3ca22` — *fix: patch os packages and drop npm cli from runtime image*

**Verification:** Trivy container scan passes with `severity: HIGH,CRITICAL` and `ignore-unfixed: true`.

### 4. npm CLI present in production image (Trivy)

**Finding:** The npm CLI and its dependency tree were present in the production runtime image after `npm install --omit=dev`, increasing the attack surface.

**Impact:** Production container — unnecessary tooling that could be exploited if combined with other vulnerabilities.

**Remediation:**
- Removed npm binaries and cache after installing production dependencies:
  ```dockerfile
  RUN npm install --omit=dev && rm -rf /usr/local/lib/node_modules/npm /usr/local/bin/npm /usr/local/bin/npx /root/.npm
  ```
- Commit: `1d3ca22` — *fix: patch os packages and drop npm cli from runtime image*

**Verification:** Trivy no longer flags npm-related packages in the final runtime image.

### 5. GitHub Actions workflows ran with default write token (CKV2_GHA_1)

**Finding:** Neither workflow declared top-level `permissions`, so every job received the repository's default `GITHUB_TOKEN` with write access. A compromised action or dependency in the pipeline could push code or tamper with releases.

**Remediation:**
- Added `permissions: contents: read` at the top level of `ci.yml` and `security-scan.yml`, restricting all jobs to read-only access

**Verification:** `checkov --framework terraform github_actions` passes with 0 failed checks.

### 6. Invalid Trivy action version (workflow fix)

**Finding:** Initial workflow referenced an invalid `trivy-action` version tag, causing the container scan job to fail before any image analysis could run.

**Remediation:**
- Pinned to a valid release: `aquasecurity/trivy-action@v0.36.0`
- Commit: `d053420` — *fix: use valid trivy-action version*

---

## Known Remaining Issues

### Dev-only dependency findings (accepted risk)

The informational full audit (`npm audit` without `--omit=dev`) still reports vulnerabilities in development tooling:

| Package | Severity | Advisory | Justification |
|---------|----------|----------|---------------|
| `esbuild` ≤ 0.24.2 | Moderate | [GHSA-67mh-4wv8-2f99](https://github.com/advisories/GHSA-67mh-4wv8-2f99) | Dev-only — affects the Vite development server, not the production build or runtime image |
| `vite` ≤ 6.4.2 | High (transitive via esbuild) | Multiple advisories | Dev-only — Vite is a build tool; the production Docker image serves pre-built static assets and does not run Vite |

**Why this is acceptable:**
- These packages are **not installed** in the production Docker image (`npm install --omit=dev` in the runtime stage only installs server dependencies).
- The blocking CI step uses `npm audit --omit=dev --audit-level=high`, which passes cleanly.
- The full audit step is informational (`continue-on-error: true`) and exists for visibility.
- Fixing `vite`/`esbuild` requires upgrading to Vite 8.x, which is a **breaking change** and is deferred to a dedicated dependency upgrade task.

**Planned action:** Upgrade Vite and related dev tooling in a future PR when the team can regression-test the frontend build.

### Checkov findings outside the CI gate (accepted risk)

A full repository scan (`checkov -d .` without a framework filter) also reports:

| Check | Resource | Justification |
|-------|----------|---------------|
| CKV_DOCKER_2 (no HEALTHCHECK) | root, `client/`, `server/` Dockerfiles | Health checks are handled by the deployment layer; `client/` and `server/` Dockerfiles are local-dev only (`docker-compose.yml`) |
| CKV_DOCKER_3 (no USER) | `client/`, `server/` Dockerfiles | Local-dev images only; the production image at the repo root already runs as a non-root `appuser` |
| CKV2_ANSIBLE_1 (HTTP uri) | `ansible/roles/application` health check task | The check targets `localhost` on the provisioned VM; traffic never leaves the host |

The CI gate is scoped to `terraform` and `github_actions` frameworks, so these do not block merges. They are documented here for visibility and can be revisited if the deployment model changes.

### Application-level security gaps (not detected by automated scans)

The following items were identified during implementation review. They are **not** reported by npm audit or Trivy but are tracked for future hardening:

| Gap | Severity | Status | Notes |
|-----|----------|--------|-------|
| No API authentication | High | Planned (Phase 2) | Endpoints are currently open; JWT auth is on the roadmap |
| No rate limiting | Medium | Planned (Phase 2) | Transaction endpoints lack `express-rate-limit` |
| Permissive CORS | Medium | Planned (Phase 2) | `cors()` is applied without origin restrictions |
| No HTTP security headers | Low | Planned (Phase 2) | Helmet.js not yet integrated |
| Error messages expose internals | Low | Partial | Some routes return `error.message` to clients |

Input validation for new transactions is implemented in [`server/src/validate.js`](server/src/validate.js) and covered by unit tests in [`server/src/validate.test.js`](server/src/validate.test.js).

---

## Running Scans Locally

Reproduce the CI security checks on your machine:

```bash
# Install dependencies
npm install

# Production dependency audit (must pass — same as CI)
npm audit --omit=dev --audit-level=high

# Full audit (informational — same as CI)
npm audit

# Container scan (requires Docker and Trivy)
docker build -t akiba-app:local .
trivy image --severity HIGH,CRITICAL --ignore-unfixed akiba-app:local

# IaC scan (requires Docker; same gate as CI)
docker run --rm -v "$PWD:/tf" bridgecrew/checkov -d /tf --framework terraform github_actions --quiet --compact
```

Install Trivy: https://aquasecurity.github.io/trivy/latest/getting-started/installation/

---

## Keeping This Document Up to Date

Update `SECURITY.md` whenever:

1. A new scanner is added to [`.github/workflows/security-scan.yml`](.github/workflows/security-scan.yml)
2. Scan triggers, severity thresholds, or blocking behavior change
3. A vulnerability is discovered and remediated (or accepted with justification)
4. A dependency upgrade changes the audit or Trivy results

After changes, re-run the local commands above and update the **Findings Summary** and **Known Remaining Issues** sections.

---

## Reporting Security Vulnerabilities

If you discover a security issue in AKIBA:

1. **Do not** open a public GitHub issue for exploitable vulnerabilities.
2. Contact the team directly (see [README.md](README.md) for team members).
3. Follow responsible disclosure — allow reasonable time for a fix before public disclosure.

---

## References

- [npm audit documentation](https://docs.npmjs.com/cli/commands/npm-audit)
- [Trivy documentation](https://aquasecurity.github.io/trivy/)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Express.js security best practices](https://expressjs.com/en/advanced/best-practice-security.html)
- [MongoDB security checklist](https://www.mongodb.com/docs/manual/administration/security-checklist/)
