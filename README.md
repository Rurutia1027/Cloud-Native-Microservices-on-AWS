# Cloud-Native Microservices on AWS

A hands-on project for **cloud-native backend engineering**, **microservices architecture**, **AWS platform design**, and **DevOps automation** on AWS.

Each AWS service is modeled as a **unit** and documented across three layers:

1. **Concept** — purpose, capabilities, and architectural role
2. **Terraform** — provisioning, configuration, and operations
3. **Microservices Integration** — runtime usage in EKS and day-2 AWS workflows

---

## Focus

- Microservices on **EKS**
- Terraform-based infrastructure automation
- CI/CD, pipelines, and platform engineering
- Observability (OpenTelemetry, CloudWatch, X-Ray)

This repo is **not** focused on analytics or big-data workloads. Data services appear only as supporting components for backend microservices.

---

## Architecture

```text
Client → API Layer (ALB / API Gateway)
      → Microservices (EKS primary; ECS / Lambda where needed)
      → Data Layer (RDS / DynamoDB / S3)
      → Event Layer (SQS / MSK / EventBridge)
      → Observability (CloudWatch / X-Ray / OpenTelemetry)
```

**Workflow:** Terraform plan/apply → provision AWS resources → deploy to EKS → connect services → observe in production

---

## Core AWS Units

| Unit | Concept | Terraform | Microservices Integration |
|---|---|---|---|
| **IAM** | RBAC, least privilege, IRSA | Roles, policies, trust relationships | EKS ServiceAccount → IAM, CI/CD roles |
| **EKS** | Managed Kubernetes platform | Cluster, node groups, networking, add-ons | Deployments, Ingress, HPA, ECR workflows |
| **VPC** | Network isolation and connectivity | VPC, subnets, SGs, NAT, endpoints | Pod networking, service exposure, secure backend access |
| **RDS** | Transactional relational storage | Instance, subnet/SG, backup, HA | Domain services, connection pooling, CQRS patterns |
| **S3** | Durable object storage | Buckets, lifecycle, encryption, policies | Pre-signed URLs, artifacts, log archival |
| **SQS** | Async decoupling | Queues, DLQ, retry config | Order/payment flows, background jobs |
| **MSK** | Event streaming | Kafka cluster, topics, access | Event-driven services, saga/outbox patterns |
| **EventBridge** | AWS-native event routing | Buses, rules, targets | Domain event orchestration |
| **API Gateway** | Unified API entry | REST API, integrations, auth | Route to EKS/Lambda, throttling |
| **Lambda** | Serverless compute | Functions, roles, triggers | Async processors, event consumers |
| **Observability** | Logs, metrics, tracing | CloudWatch, alarms, tracing setup | End-to-end request visibility |

---

## CI/CD

```text
Source → CI Pipeline → Docker Build → ECR → EKS Deploy → Observability Validation
```

Terraform also manages Jenkins infrastructure, IAM for deployment, and ECR repositories for a reproducible local-to-cloud delivery path.

---

## Local Development

- Docker Compose / Kind
- Local Kafka, PostgreSQL, MongoDB
- LocalStack for AWS emulation

---

## Learning Roadmap

Each unit is rated on three dimensions:

| Dimension | Meaning |
|---|---|
| **Difficulty** | Concept depth + debug complexity |
| **Cost** | Real AWS spend when running hands-on labs |
| **Interview** | How often it appears in cloud-native / DevOps interviews |

**Legend:** ★ = low · ★★★ = medium · ★★★★★ = high

### Difficulty / Cost / Interview Trend

```text
High ┤                              MSK / Kafka
     │                         EKS  ██████████
     │                         IAM  █████████
     │                 Terraform ████████
     │                 RDS       ███████
     │          API Gateway     ██████
     │          Lambda          ██████
     │      SQS / EventBridge  █████
     │      CloudWatch        █████
     │  S3                   ███
Low  └──────────────────────────────────────────────→
       Foundation        Intermediate        Advanced Cloud-Native
```

### Tier Classification

#### S-Tier — Core Hard + Core Interview

| Unit | Difficulty | Cost | Interview | Why It Matters |
|---|---|---|---|---|
| **EKS** | ★★★★★ | ★★★★☆ | ★★★★★ | CNI networking, Pod lifecycle, Ingress/Service/HPA, IAM + IRSA — AWS + Kubernetes + networking + scaling in one system |
| **IAM** | ★★★★☆ | ★ | ★★★★★ | Assume role, policy evaluation, cross-account design — the security kernel of AWS |
| **MSK / Kafka** | ★★★★★ | ★★★★★ | ★★★★☆ | Partitioning, ordering, consumer groups, replay semantics — most abstract and most expensive |

#### A-Tier — Cloud-Native Core

| Unit | Difficulty | Cost | Interview | Why It Matters |
|---|---|---|---|---|
| **RDS** | ★★★☆☆ | ★★★☆☆ | ★★★★☆ | Failover, read replicas, connection pooling |
| **Lambda** | ★★★☆☆ | ★☆☆☆☆ | ★★★★☆ | Event-driven thinking, cold start, stateless design |
| **API Gateway** | ★★★☆☆ | ★★☆☆☆ | ★★★☆☆ | Unified API entry, routing, auth integration |
| **SQS / EventBridge** | ★★★☆☆ | ★☆☆☆☆ | ★★★★☆ | Decoupling microservices — essential integration tools |

#### B-Tier — Foundation (Must-Know)

| Unit | Difficulty | Cost | Interview | Why It Matters |
|---|---|---|---|---|
| **S3** | ★☆☆☆☆ | ★☆☆☆☆ | ★★★☆☆ | Simplest AWS unit — object storage baseline |
| **CloudWatch** | ★★☆☆☆ | ★★☆☆☆ | ★★★★☆ | Logs, metrics, alarms — critical for production ops |
| **Terraform** | ★★★★☆ | ★☆☆☆☆ | ★★★★★ | IaC is a core skill for this repo's direction — not optional |

---

### Progressive Learning Phases

Follow phases in order. Each phase builds on the previous one.

| Phase | Units | Tier | Est. Focus | Status |
|---|---|---|---|---|
| **1 — Foundation** | S3, CloudWatch | B | Object storage + observability basics | ⬜ |
| **2 — Infrastructure as Code** | Terraform (modules, state, env separation) | B+ | Reproducible provisioning before touching complex services | ⬜ |
| **3 — Security Core** | IAM (roles, policies, IRSA prep) | S | Security kernel — required before EKS and CI/CD | ⬜ |
| **4 — Async & Serverless** | SQS, EventBridge, Lambda | A | Event-driven decoupling and stateless compute | ⬜ |
| **5 — API Layer** | API Gateway, ALB basics | A | External entry point and request routing | ⬜ |
| **6 — Data Layer** | RDS (+ VPC networking basics) | A | Transactional storage, HA, connection management | ⬜ |
| **7 — Platform Core** | VPC (deep dive), EKS | S | Kubernetes platform — primary runtime for microservices | ⬜ |
| **8 — Event Streaming** | MSK / Kafka | S | Saga, outbox, replay — advanced event-driven patterns | ⬜ |
| **9 — End-to-End Integration** | CI/CD pipeline, full stack deploy | S+ | Local → ECR → EKS → observe in production | ⬜ |

> **Cost tip:** Phases 1–5 are low cost. Phase 6+ introduces always-on resources. Tear down EKS and MSK clusters after each lab session.

### Per-Unit Learning Checklist

Each unit follows the same three-layer path. Mark complete when all three are done.

| Unit | Concept | Terraform | Microservices Integration |
|---|---|---|---|
| S3 | ⬜ | ⬜ | ⬜ |
| CloudWatch | ⬜ | ⬜ | ⬜ |
| Terraform | ⬜ | ⬜ | ⬜ |
| IAM | ⬜ | ⬜ | ⬜ |
| SQS | ⬜ | ⬜ | ⬜ |
| EventBridge | ⬜ | ⬜ | ⬜ |
| Lambda | ⬜ | ⬜ | ⬜ |
| API Gateway | ⬜ | ⬜ | ⬜ |
| RDS | ⬜ | ⬜ | ⬜ |
| VPC | ⬜ | ⬜ | ⬜ |
| EKS | ⬜ | ⬜ | ⬜ |
| MSK | ⬜ | ⬜ | ⬜ |

---

## Learning Outcomes

- Cloud-native microservices design
- EKS-centered AWS architecture
- Modular Terraform and reproducible environments
- CI/CD automation and observability-driven operations

---

## Future Work

Multi-region deployment, GitOps (Argo CD), service mesh, advanced autoscaling (HPA / KEDA), GitHub Actions / CodePipeline, reusable Terraform modules, cost optimization

---

**Summary:** A structured path from **Concept → Terraform → Microservices Integration → CI/CD → Observability**, with **EKS** as the core runtime and **DevOps/platform engineering** as the operational backbone.
