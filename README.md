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

## Storage Architecture
* **Working Directories (`_work`)**: Mounted to compressed `zram` RAM disks on each host (`/mnt/data/github_runners/work` and `/mnt/largedata/github_runners/work`) for ultra-fast, isolated compilation.
* **Apt Cache**: Mounted to NAS (`/mnt/sharedroot/data/apt-cache`) to reduce redundant package downloads across the fleet.
* **Outputs**: Mounted to NAS (`/mnt/sharedroot/github_runners/<node>`) for persistent artifact storage.

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
