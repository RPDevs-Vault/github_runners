#!/bin/bash
set -e

echo "🚀 Starting Remote NFS over Cloudflare Tunnel Setup..."

# 1. Install cloudflared if it doesn't exist
if ! command -v cloudflared &> /dev/null; then
    echo "⬇️ Installing cloudflared..."
    curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
    sudo dpkg -i cloudflared.deb
    rm cloudflared.deb
else
    echo "✅ cloudflared is already installed."
fi

# 2. Create the systemd service
echo "⚙️ Configuring systemd service for Cloudflare Tunnel..."
cat << 'EOF' | sudo tee /etc/systemd/system/cloudflared-nfs.service > /dev/null
[Unit]
Description=Cloudflare Tunnel for NFS
After=network-online.target

[Service]
Type=simple
User=root
Environment="TUNNEL_SERVICE_AUTH_ID=105344432816f1ea3c0d2c7dab61e02f.access"
Environment="TUNNEL_SERVICE_AUTH_SECRET=2123c85e999291747f20617fe0811374ef7dc665e9eefa543f4cdb41ac376188"
ExecStart=/usr/bin/cloudflared access tcp --hostname nfs-sharedroot.iamrp.dev --url 127.0.0.1:2049
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# 3. Enable and start the service
echo "🔄 Starting cloudflared-nfs background service..."
sudo systemctl daemon-reload
sudo systemctl enable --now cloudflared-nfs.service

# 4. Create the mount point
echo "📁 Creating mount directory at /mnt/sharedroot..."
sudo mkdir -p /mnt/sharedroot

# 5. Configure auto-mount in /etc/fstab
FSTAB_ENTRY="127.0.0.1:/mnt/sharedroot  /mnt/sharedroot  nfs  port=2049,soft,timeo=100,retrans=2,_netdev,x-systemd.requires=cloudflared-nfs.service  0 0"

if ! grep -q "127.0.0.1:/mnt/sharedroot" /etc/fstab; then
    echo "📝 Adding NFS mount to /etc/fstab..."
    echo "$FSTAB_ENTRY" | sudo tee -a /etc/fstab > /dev/null
else
    echo "✅ NFS mount already exists in /etc/fstab."
fi

# 6. Mount the directory
echo "🔗 Mounting the NFS share..."
sudo mount /mnt/sharedroot || echo "⚠️ Mount failed. Check network or if nfs-common is installed (sudo apt install nfs-common)."

echo "🎉 Setup complete! You can verify by running: ls -la /mnt/sharedroot"
