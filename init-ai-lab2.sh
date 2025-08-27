#!/bin/bash
set -e

echo "Creating repo structure: ai-agentic-lab"

# Root structure
mkdir -p ai-agentic-lab/{app/gateway,charts,k8s,terraform,docs}

# App structure
mkdir -p ai-agentic-lab/app/{src,tests}

# Gateway structure
mkdir -p ai-agentic-lab/gateway/src/main/java/com/agentic/gateway
mkdir -p ai-agentic-lab/gateway/src/test/java/com/agentic/gateway

# Docs
mkdir -p ai-agentic-lab/docs/diagrams

# Docker compose
cat <<EOF > ai-agentic-lab/docker-compose.yaml
version: "3.9"
services:
  app:
    build: ./app
    ports:
      - "8081:8081"
  gateway:
    build: ./gateway
    ports:
      - "8080:8080"
EOF

# Makefile
cat <<EOF > ai-agentic-lab/Makefile
.PHONY: build up down

build:
\tdocker-compose build

up:
\tdocker-compose up -d

down:
\tdocker-compose down
EOF

# README
cat <<EOF > ai-agentic-lab/README.md
# AI Agentic Lab

This repo contains a full-stack setup for AI Agentic development:
- **app/**: FastAPI + RAG + Agent service
- **gateway/**: Spring Boot API Gateway
- **charts/**: Helm charts for Kubernetes
- **k8s/**: Raw Kubernetes manifests
- **terraform/**: IaC for AWS EKS/ECR
EOF

# Sample test file (FIXED)
cat <<EOF > ai-agentic-lab/app/tests/test_rag.py
def test_dummy():
    assert 1 + 1 == 2
EOF

echo "✅ Repo ai-agentic-lab initialized!"