# Centralized GitHub Runners

This repository manages the deployment configurations for the RPDevs ecosystem build fleet.

## Target OS-Specific Builders with GitHub Runner Groups
The fleet has been refactored from a multi-tenant generic design into a highly targeted, OS-specific architecture utilizing **GitHub Runner Groups**. Each host runs a discrete set of runners representing key target platforms:
1. **Linux Builders** (`linux-builders` group): Optimized for fast compiling and container builds.
2. **macOS Builders** (`macos-builders` group): Specialized for macOS/iOS tooling and targets.
3. **Windows Builders** (`windows-builders` group): Specialized for Windows execution environments.

Runners are perfectly duplicated across two primary organizations:
- **RPDevs-Builds**: High-frequency workflows, package builds, and integrations.
- **RPDevs-Vault**: Archival, management, and governance workflows.

## Dynamic Fallback System & Intelligent Routing
All build workflows feature a dynamic pre-job status check (`check-runner`). 
* If a local runner is **online**, the workflow runs on our high-performance local fleet.
* If all local runners are **offline**, the workflow automatically falls back to GitHub-hosted runners (`ubuntu-latest` or `macos-latest`) to ensure builds are never blocked.
* **Duration-Based Escalation:** Workflows query the GitHub CLI for historical build durations. Workloads historically taking longer than 15 minutes are intelligently escalated from lightweight to heavy runner nodes to save idle compute on lighter nodes.

## Fleet Nodes & Hardware Limits
1. **llmadmin01**: High-performance primary node. Runners are strictly bounded to **6 CPUs** and **12GB RAM** to protect the host workstation's primary performance.
2. **T430**: Auxiliary/Parallel node. Runners are bounded to **3 CPUs** and **6GB RAM** allocated dynamically.

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
