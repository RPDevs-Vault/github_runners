# Centralized GitHub Runners

This repository manages the deployment configurations for the RPDevs ecosystem build fleet.

## Multi-Tenant Architecture
The fleet is configured as a multi-tenant grid supporting:
1. **RPDevs-Vault** (Org): Archival and Infrastructure Management.
2. **RPDevs-Builds** (Org): High-frequency Kodi Core and Addon Builds.
3. **IamRPDev** (User): Personal developer actions.

## Fleet Nodes
1. **llmadmin01**: High-performance primary node (10 threads, 16GB RAM allocation).
2. **T430**: Auxiliary/Parallel node (3 CPUs, 4GB RAM allocation).

## Thin Runner Architecture
The fleet uses a **"Thin Runner"** model where multi-gigabyte SDKs and toolchains are not baked into the Docker image. Instead, they are stored as centralized tarballs in `/mnt/sharedroot/github_runners/shared/appdata` and automatically staged to the runner's local fast storage (SSD/Zram) on startup.

### Label-Based Auto-Provisioning
The `entrypoint.sh` script detects the runner's `RUNNER_LABELS` and automatically extracts the required dependencies:
*   **`linux64`**: Provisions OpenJDK 17, Node.js 24, and pre-compiled Kodi Depends for Linux.
*   **`android-arm64`**: Provisions Android SDK/NDK, OpenJDK 17, and Android Kodi Depends.
*   **`osx64`**: Provisions macOS Kodi Depends (when running on self-hosted).

## Depends-as-a-Service (DaaS)
Kodi's `tools/depends` system is pre-compiled weekly via the **Build and Archive Kodi Depends** workflow in this repository. 

*   **Workflow**: `.github/workflows/build-depends.yml`
*   **Output Path**: `shared/appdata/kodi-depends/<os>/depends.tar.gz`
*   **Benefit**: Reduces Kodi Core build times from 60+ minutes to under 15 minutes.

---

## 🚀 Deployment Instructions

### 1. Initial Sync
On the target machine (llmadmin01 or T430), ensure you have the latest configurations:
```bash
cd /mnt/data/github_runners # (or /mnt/largedata/github_runners on llmadmin01)
git pull origin main
```

### 2. "Activate" Node Configuration
Since this repository manages multiple nodes, you must link the correct configuration to the root of your local folder:
```bash
# On T430:
ln -sf T430/docker-compose.yml .

# On llmadmin01:
ln -sf llmadmin01/docker-compose.yml .
```

### 3. Setup Flex Drive (Zram Writeback)
Ensure your workspace is fast and expandable:
```bash
# On T430 (32G Total, 4G RAM Limit)
sudo ./setup_flex_zram.sh /mnt/data/github_runners/work /mnt/data/github_runners/workflex/zram_back 4G 32G
```

### 4. Start Runners
```bash
# Ensure GH_PAT is set in your environment
export GH_PAT=your_token_here
docker-compose pull && docker-compose up -d
```

---

## 🛠️ Troubleshooting

### Missing `docker-compose`?
If `docker-compose` is not installed on your system:
```bash
sudo apt-get update
sudo apt-get install -y docker-compose
```

### Permission Denied on Work Dir?
If the runners fail to start with permission errors:
```bash
sudo chown -R 1000:1000 /mnt/data/github_runners/work
```
