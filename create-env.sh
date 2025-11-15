#!/bin/bash

## Create the network with new subnet
docker network create --subnet=172.25.0.0/16 prometheus_env

## Create the directories for each environment
mkdir -p ${HOME}/grafana-prometheus/prom1
mkdir -p ${HOME}/grafana-prometheus/prom2

## Copy the configuration files
cp prom1.yml ${HOME}/grafana-prometheus/prom1/prometheus.yml
cp prom2.yml ${HOME}/grafana-prometheus/prom2/prometheus.yml

## Create the first Prometheus environment
docker run -d -p 9200:9090 \
  -v ${HOME}/grafana-prometheus/prom1:/etc/prometheus \
  --name=prom1 \
  --network=prometheus_env \
  --ip 172.25.0.10 \
  prom/prometheus

docker run -d --name=node1 --network=prometheus_env --ip 172.25.0.11 prom/node-exporter
docker run -d --name=node2 --network=prometheus_env --ip 172.25.0.12 prom/node-exporter

## Create the second Prometheus environment
docker run -d -p 9300:9090 \
  -v ${HOME}/grafana-prometheus/prom2:/etc/prometheus \
  --name=prom2 \
  --network=prometheus_env \
  --ip 172.25.0.20 \
  prom/prometheus

docker run -d --name=node3 --network=prometheus_env --ip 172.25.0.21 prom/node-exporter
docker run -d --name=node4 --network=prometheus_env --ip 172.25.0.22 prom/node-exporter

## Run Grafana (connected to the same network)
docker run -d -p 3000:3000 \
  --name=grafana \
  --network=prometheus_env \
  --ip 172.25.0.100 \
  grafana/grafana-enterprise:12.2.1-ubuntu
