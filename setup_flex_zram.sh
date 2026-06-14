#!/bin/bash
# setup_flex_zram.sh - Configure zram with a physical backing store (Flex Drive)
# Usage: sudo ./setup_flex_zram.sh <mount_point> <backing_file> <ram_limit> <total_size>

MOUNT_POINT=$1      # e.g., /mnt/largedata/github_runners/work
BACKING_FILE=$2     # e.g., /mnt/largedata/github_runners/workflex/zram_back
RAM_LIMIT=$3        # e.g., 8G
TOTAL_SIZE=$4       # e.g., 64G

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

if [[ -z "$MOUNT_POINT" || -z "$BACKING_FILE" || -z "$RAM_LIMIT" || -z "$TOTAL_SIZE" ]]; then
    echo "Usage: $0 <mount_point> <backing_file> <ram_limit> <total_size>"
    exit 1
fi

echo "🚀 Starting Flex Drive setup for $MOUNT_POINT..."

# 1. Unmount existing if necessary
if mountpoint -q "$MOUNT_POINT"; then
    echo "📦 Unmounting $MOUNT_POINT..."
    umount -l "$MOUNT_POINT"
fi

# 2. Add a fresh zram device
NEW_ID=$(cat /sys/class/zram-control/hot_add)
ZRAM_DEV="/dev/zram$NEW_ID"
echo "🆕 Created new device: $ZRAM_DEV"

# 3. Create backing file directory
mkdir -p "$(dirname "$BACKING_FILE")"

# 4. Create sparse backing file if it doesn't exist
if [[ ! -f "$BACKING_FILE" ]]; then
    echo "💾 Creating sparse backing file: $BACKING_FILE ($TOTAL_SIZE)..."
    truncate -s "$TOTAL_SIZE" "$BACKING_FILE"
    chmod 600 "$BACKING_FILE"
fi

# 5. Setup loop device for the backing file
LOOP_DEV=$(losetup -j "$BACKING_FILE" | cut -d: -f1)
if [[ -z "$LOOP_DEV" ]]; then
    LOOP_DEV=$(losetup -fP "$BACKING_FILE" --show)
    echo "🔄 Mapped $BACKING_FILE to $LOOP_DEV"
else
    echo "✅ Backing file already mapped to $LOOP_DEV"
fi

# 6. Configure backing device
echo "🔗 Attaching $LOOP_DEV to $ZRAM_DEV backing_dev..."
echo "$LOOP_DEV" > "/sys/block/zram$NEW_ID/backing_dev"

# 7. Set RAM limit (mem_limit)
echo "🧠 Setting RAM limit to $RAM_LIMIT..."
echo "$RAM_LIMIT" > "/sys/block/zram$NEW_ID/mem_limit"

# 8. Set total disk size
echo "📏 Setting total disk size to $TOTAL_SIZE..."
echo "$TOTAL_SIZE" > "/sys/block/zram$NEW_ID/disksize"

# 9. Format and Mount
echo "🔨 Formatting $ZRAM_DEV with XFS..."
mkfs.xfs -f "$ZRAM_DEV"

echo "📂 Mounting to $MOUNT_POINT..."
mkdir -p "$MOUNT_POINT"
mount "$ZRAM_DEV" "$MOUNT_POINT"
chown -R 1000:1000 "$MOUNT_POINT"

echo "✅ Flex Drive setup complete!"
zramctl "$ZRAM_DEV"
