#!/bin/bash

set -e

dnf update -y

dnf install -y wget tar

# =========================
# Docker
# =========================

dnf install -y docker

systemctl enable docker
systemctl start docker


# =========================
# Prometheus
# =========================

useradd --no-create-home --shell /bin/false prometheus || true

cd /tmp

wget https://github.com/prometheus/prometheus/releases/download/v3.5.0/prometheus-3.5.0.linux-amd64.tar.gz

tar -xzf prometheus-3.5.0.linux-amd64.tar.gz

cd prometheus-3.5.0.linux-amd64

cp prometheus /usr/local/bin/
cp promtool /usr/local/bin/

mkdir -p /etc/prometheus
mkdir -p /var/lib/prometheus


cat > /etc/prometheus/prometheus.yml <<EOF
global:
  scrape_interval: 15s

scrape_configs:

  - job_name: "prometheus"
    static_configs:
      - targets:
          - "localhost:9090"

  - job_name: "node-exporter"
    static_configs:
      - targets:
          - "localhost:9100"

  - job_name: "application-servers"
    static_configs:
      - targets:
%{ for server in application_servers ~}
          - "${server}"
%{ endfor ~}
EOF


chown -R prometheus:prometheus /etc/prometheus
chown -R prometheus:prometheus /var/lib/prometheus


# =========================
# Node Exporter
# =========================

cd /tmp

wget https://github.com/prometheus/node_exporter/releases/download/v1.9.1/node_exporter-1.9.1.linux-amd64.tar.gz

tar -xzf node_exporter-1.9.1.linux-amd64.tar.gz

cp node_exporter-1.9.1.linux-amd64/node_exporter /usr/local/bin/


# =========================
# Prometheus Service
# =========================

cat > /etc/systemd/system/prometheus.service <<EOF
[Unit]
Description=Prometheus
After=network.target

[Service]
User=prometheus
Group=prometheus
ExecStart=/usr/local/bin/prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/var/lib/prometheus
Restart=always

[Install]
WantedBy=multi-user.target
EOF


# =========================
# Node Exporter Service
# =========================

cat > /etc/systemd/system/node-exporter.service <<EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
ExecStart=/usr/local/bin/node_exporter
Restart=always

[Install]
WantedBy=multi-user.target
EOF


systemctl daemon-reload

systemctl enable prometheus
systemctl start prometheus

systemctl enable node-exporter
systemctl start node-exporter


# =========================
# Grafana
# =========================

cat > /etc/yum.repos.d/grafana.repo <<EOF
[grafana]
name=grafana
baseurl=https://rpm.grafana.com
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://rpm.grafana.com/gpg.key
EOF

dnf install -y grafana

systemctl enable grafana-server
systemctl start grafana-server


echo "========================================="
echo "Monitoring setup completed successfully"
echo "========================================="