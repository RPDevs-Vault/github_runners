# ⚙️ Unified Workflows Registry

This directory contains the synchronized source-of-truth copies for all active workflows running across the RPDevs-Vault ecosystem.

Following the **2-Core Manager Architecture**, these workflows are logically categorized and managed by their respective core engines, but are mirrored here to provide total visibility for runner node configuration and auditing.

---

## 🏗 Tier 1: DevOps-Manager (Global Control Hub)

The `devops-manager` acts as the primary governance, telemetry, and notification controller for the organization.
Workflows managed by `devops-manager` include:

*   **`archive-lifecycle-engine.yml`**: Manages the archival of stale repositories and resources.
*   **`global-health-engine.yml`**: Centralized status checks, tracking, and organization-wide health monitoring.
*   **`governance-engine.yml`**: Enforces organizational policies, issue standardization, and PR management.
*   **`notification-manager.yml`**: Dispatches global alerts and status updates across chatops channels.
*   *(And other global administrative processes)*

## 💾 Centralized NFS Cache System

To take full advantage of our self-hosted runner fleet and NFS mounts, all workflows executing on `linux64` runners should explicitly target the shared cache directories to maximize build speed.

Configure your jobs with the following global environment variables when appropriate:

```yaml
env:
  ANDROID_SDK_ROOT: /mnt/sharedroot/github_runners/shared/android-sdk
  CARGO_HOME: /mnt/sharedroot/github_runners/shared/cargo-home
  GOCACHE: /mnt/sharedroot/github_runners/shared/go-cache
  PIP_CACHE_DIR: /mnt/sharedroot/github_runners/shared/pip-cache
  POETRY_CACHE_DIR: /mnt/sharedroot/github_runners/shared/poetry-cache
  NPM_CONFIG_CACHE: /mnt/sharedroot/github_runners/shared/npm-cache
  CCACHE_DIR: /mnt/sharedroot/github_runners/shared/ccache
  DOCKER_CONFIG: /mnt/sharedroot/github_runners/shared/docker-cache
```

## 🏭 Tier 2: Builder-Manager (Build & Dependency Engine)

The `builder-manager` acts as the organization's CI/CD workhorse, dynamically distributing builds and handling dependencies.
Workflows managed by `builder-manager` include:

*   **`registry-manager.yml`**: The unified engine that orchestrates package updates, OCI mirroring, GHCR auditing, stale package cleanup, and automated dependency scanning. This single engine replaces the legacy `docker-collector`, `ghcr-auditor`, `oci-mirror`, `stale-package-cleanup`, `scan-dependencies`, and `dependency-engine` workflows.
*   **`build-engine.yml`**: The heavy-duty compilation matrix engine.
*   *(And other asset build, cache warmup, and testing workflows)*

---

### Note to Infrastructure Maintainers

To ensure strict architectural consistency:
1. **Do not modify workflows directly in this directory.**
2. All changes must be committed upstream to the `ops-manager` or `builder-manager` repositories. 
3. Changes will automatically sync downstream to this directory.
