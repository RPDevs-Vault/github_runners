# Centralized GitHub Runners

This repository manages the deployment configurations for the RPDevs ecosystem build fleet.

## Super Runner Multi-Tenant Architecture
The fleet is configured as a multi-tenant grid using **Super Runners** that share all host resources instead of dividing CPU/Memory limits. Each tenant runs exactly one Super Runner container per node, registered with all relevant resource/platform labels:
1. **RPDevs-Vault** (Org): Archival and Infrastructure Management. Labeled: `self-hosted, linux64, lightweight, medium, heavy`.
2. **RPDevs-Builds** (Org): High-frequency Kodi Core and Addon Builds. Labeled: `self-hosted, linux64, lightweight, medium, heavy`.
3. **IamRPDev** (User): Personal developer actions. Labeled: `self-hosted, linux64, lightweight`.

## Dynamic Fallback System
All build workflows feature a dynamic pre-job status check (`check-runner`). 
* If a local runner is **online**, the workflow runs on our high-performance local fleet.
* If all local runners are **offline**, the workflow automatically falls back to GitHub-hosted runners (`ubuntu-latest` or `macos-latest`) to ensure builds are never blocked.
* The API calls authenticate using the centralized `GH_TOKEN` secret.

## Fleet Nodes
1. **llmadmin01**: High-performance primary node (10 threads, 16GB RAM shared dynamically).
2. **T430**: Auxiliary/Parallel node (3 CPUs, 4.5GB RAM allocated dynamically across two runners).

## Centralized AppData
Multi-gigabyte SDKs and toolchains are stored centrally in `/mnt/sharedroot/github_runners/` (e.g., the pre-staged `/mnt/sharedroot/github_runners/android-sdk` is mounted directly to `/opt/android-sdk`), eliminating setup/copy overhead on startup.

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
