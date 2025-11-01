sudo yum update -y
sudo yum install wget -y
sudo yum install java-17-amazon-corretto -y

sudo mkdir -p /app && cd /app
sudo wget https://download.sonatype.com/nexus/3/nexus-3.85.0-03-linux-x86_64.tar.gz
sudo tar -xvf nexus-3.85.0-03-linux-x86_64.tar.gz
sudo mv nexus-3.85.0-03 nexus

sudo adduser nexus
sudo mkdir -p /app/sonatype-work
sudo chown -R nexus:nexus /app/nexus /app/sonatype-work

# Set nexus user
sudo sed -i 's|^#run_as_user=.*|run_as_user="nexus"|' /app/nexus/bin/nexus

# Create systemd service
sudo tee /etc/systemd/system/nexus.service > /dev/null << EOL
[Unit]
Description=Nexus Repository Manager
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
User=nexus
Group=nexus
ExecStart=/app/nexus/bin/nexus start
ExecStop=/app/nexus/bin/nexus stop
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOL

# Enable and start Nexus
sudo systemctl daemon-reload
sudo systemctl enable nexus
sudo systemctl start nexus
sudo systemctl status nexus
