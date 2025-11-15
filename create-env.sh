#!/bin/bash
set -e

BASE_DIR="$HOME/grafana-prometheus"

# ------------------------------------------------------------------
# 1. Create network (172.25.0.0/16)
# ------------------------------------------------------------------
docker network create --subnet=172.25.0.0/16 prometheus_env || true

# ------------------------------------------------------------------
# 2. Prepare directories & copy config files
# ------------------------------------------------------------------
mkdir -p "$BASE_DIR/prom1" "$BASE_DIR/prom2"

cp "$BASE_DIR/prom1.yml" "$BASE_DIR/prom1/prometheus.yml"
cp "$BASE_DIR/prom2.yml" "$BASE_DIR/prom2/prometheus.yml"

# ------------------------------------------------------------------
# 3. First Prometheus environment (prom1 + node1 + node2)
# ------------------------------------------------------------------
docker run -d -p 9200:9090 \
  -v "$BASE_DIR/prom1":/etc/prometheus \
  --name=prom1 \
  --network=prometheus_env \
  --ip 172.25.0.10 \
  prom/prometheus

docker run -d --name=node1 --network=prometheus_env --ip 172.25.0.11 prom/node-exporter
docker run -d --name=node2 --network=prometheus_env --ip 172.25.0.12 prom/node-exporter

# ------------------------------------------------------------------
# 4. Second Prometheus environment (prom2 + node3 + node4)
# ------------------------------------------------------------------
docker run -d -p 9300:9090 \
  -v "$BASE_DIR/prom2":/etc/prometheus \
  --name=prom2 \
  --network=prometheus_env \
  --ip 172.25.0.20 \
  prom/prometheus

docker run -d --name=node3 --network=prometheus_env --ip 172.25.0.21 prom/node-exporter
docker run -d --name=node4 --network=prometheus_env --ip 172.25.0.22 prom/node-exporter

# ------------------------------------------------------------------
# 5. Grafana (persistent storage optional)
# ------------------------------------------------------------------
docker run -d -p 3000:3000 \
  --name=grafana \
  --network=prometheus_env \
  --ip 172.25.0.100 \
  -v "$BASE_DIR/grafana-data":/var/lib/grafana \
  grafana/grafana-enterprise:12.2.1-ubuntu

echo "Setup complete!"
echo "  Prometheus 1 → http://<host>:9200"
echo "  Prometheus 2 → http://<host>:9300"
echo "  Grafana      → http://<host>:3000 (admin/admin)"
