#!/bin/bash
# ============================================================
# Script: init_repo.sh
# Purpose: Bootstrap AI Agentic Lab repo structure
# ============================================================

set -e

REPO="ai-agentic-lab"

echo "🚀 Creating repo structure: $REPO"

mkdir -p $REPO/{app,gateway,charts,k8s,terraform,docs}

# --- Python FastAPI (RAG + Agent service) ---
cat > $REPO/app/service.py <<'EOF'
from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI(title="RAG + Agent Service")

class QueryRequest(BaseModel):
    query: str

@app.post("/ask")
async def ask(req: QueryRequest):
    return {"answer": f"Placeholder response for: {req.query}"}
EOF

cat > $REPO/app/requirements.txt <<'EOF'
fastapi
uvicorn
langchain
chromadb
pydantic
EOF

echo "print('Run pytest here')" > $REPO/app/tests/test_rag.py

cat > $REPO/app/Dockerfile <<'EOF'
FROM python:3.10-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
CMD ["uvicorn", "service:app", "--host", "0.0.0.0", "--port", "8080"]
EOF

# --- Java Spring Boot Gateway ---
mkdir -p $REPO/gateway/src/main/java/com/example/gateway
mkdir -p $REPO/gateway/src/test/java/com/example/gateway

cat > $REPO/gateway/src/main/java/com/example/gateway/GatewayApplication.java <<'EOF'
package com.example.gateway;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class GatewayApplication {
    public static void main(String[] args) {
        SpringApplication.run(GatewayApplication.class, args);
    }
}
EOF

cat > $REPO/gateway/src/main/java/com/example/gateway/RagProxyController.java <<'EOF'
package com.example.gateway;

import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;

import java.util.Map;

@RestController
@RequestMapping("/api")
public class RagProxyController {
    private final RestTemplate restTemplate = new RestTemplate();

    @PostMapping("/ask")
    public Map<String, Object> ask(@RequestBody Map<String, String> payload) {
        return restTemplate.postForObject("http://rag-api:8080/ask", payload, Map.class);
    }
}
EOF

cat > $REPO/gateway/pom.xml <<'EOF'
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.example</groupId>
    <artifactId>gateway</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <packaging>jar</packaging>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.2</version>
    </parent>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
EOF

cat > $REPO/gateway/Dockerfile <<'EOF'
FROM eclipse-temurin:17-jdk-alpine
WORKDIR /app
COPY . .
RUN ./mvnw package -DskipTests
CMD ["java", "-jar", "target/gateway-0.0.1-SNAPSHOT.jar"]
EOF

# --- Helm Chart placeholder ---
mkdir -p $REPO/charts/rag-api/templates
cat > $REPO/charts/rag-api/Chart.yaml <<'EOF'
apiVersion: v2
name: rag-api
version: 0.1.0
EOF

# --- Kubernetes manifests placeholder ---
cat > $REPO/k8s/rag-api-deployment.yaml <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rag-api
spec:
  replicas: 1
  selector:
    matchLabels:
      app: rag-api
  template:
    metadata:
      labels:
        app: rag-api
    spec:
      containers:
      - name: rag-api
        image: rag-api:latest
        ports:
        - containerPort: 8080
EOF

# --- Terraform placeholders ---
cat > $REPO/terraform/providers.tf <<'EOF'
provider "aws" {
  region = "us-east-1"
}
EOF

cat > $REPO/terraform/eks.tf <<'EOF'
# Placeholder for EKS cluster definition
EOF

# --- docker-compose ---
cat > $REPO/docker-compose.yaml <<'EOF'
version: "3.9"

services:
  chroma:
    image: chromadb/chroma:latest
    ports:
      - "8000:8000"

  rag-api:
    build: ./app
    ports:
      - "8080:8080"
    depends_on:
      - chroma

  gateway:
    build: ./gateway
    ports:
      - "8081:8081"
    depends_on:
      - rag-api

  ollama:
    image: ollama/ollama:latest
    ports:
      - "11434:11434"
    volumes:
      - ollama-models:/root/.ollama

volumes:
  ollama-models:
EOF

# --- Makefile ---
cat > $REPO/Makefile <<'EOF'
.PHONY: build run down test logs

build:
	docker-compose build

run:
	docker-compose up

down:
	docker-compose down -v

test:
	cd app && pytest -v

logs:
	docker-compose logs -f
EOF

# --- Docs & README ---
cat > $REPO/docs/architecture.md <<'EOF'
# Architecture Overview

This system implements a RAG + Agent stack with:
- Python FastAPI for RAG service
- LangChain for agent orchestration
- ChromaDB as vector store
- Ollama for local LLM runtime
- Spring Boot Gateway for API routing
EOF

cat > $REPO/README.md <<'EOF'
# AI Agentic Lab

End-to-end home lab for AI, RAG, Agents, LangChain, LLMs/SLMs with:
- Python FastAPI RAG service
- Java Spring Boot Gateway
- Docker Compose for local dev
- Helm/K8s for deployment
- Terraform for AWS infra

See docs/architecture.md for details.
EOF

echo "✅ Repo structure created successfully at: $REPO"