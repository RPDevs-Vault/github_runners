#!/bin/bash
# bootstrap.sh - Quickly activate and setup runners for a specific node

NODE=$1

if [[ -z "$NODE" ]]; then
    echo "Usage: $0 <llmadmin01|T430>"
    exit 1
fi

if [[ ! -d "$NODE" ]]; then
    echo "Error: Node directory '$NODE' not found."
    exit 1
fi

echo "🚀 Bootstrapping node: $NODE"

# 1. Link docker-compose
echo "🔗 Linking $NODE/docker-compose.yml to root..."
ln -sf "$NODE/docker-compose.yml" ./docker-compose.yml

# 2. Set permissions for setup script
chmod +x setup_flex_zram.sh

# 3. Detect mount point based on node
if [[ "$NODE" == "llmadmin01" ]]; then
    WORK_DIR="/mnt/largedata/github_runners/work"
    FLEX_DIR="/mnt/largedata/github_runners/workflex"
    RAM_LIMIT="8G"
    TOTAL_SIZE="64G"
else
    WORK_DIR="/mnt/data/github_runners/work"
    FLEX_DIR="/mnt/data/github_runners/workflex"
    RAM_LIMIT="4G"
    TOTAL_SIZE="32G"
fi

echo ""
echo "✅ Node activated!"
echo "--------------------------------------------------------"
echo "Next Steps:"
echo "1. Run Flex Drive setup (requires sudo):"
echo "   sudo ./setup_flex_zram.sh $WORK_DIR $FLEX_DIR/zram_back $RAM_LIMIT $TOTAL_SIZE"
echo ""
echo "2. Start your runners:"
echo "   export GH_PAT=your_token_here"
echo "   docker-compose pull && docker-compose up -d"
echo "--------------------------------------------------------"
