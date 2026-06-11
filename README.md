# Cloud Native Microservices on AWS
## Overview 
This repository showcases a full cloud-native setup that combines **microservices architecture** with **AWS managed services**. The goal is to map common open-source components to their AWS equivalents, and manage infrastructure declaratively using **Terraform**. 

It demonstrates: 
- Microservices communication patterns
- Observability and tracing
- Scalable and resilient cloud architecture
- Terraform-based infrastructure automation

## Terraform Integration 
Terraform managed: 
- VPC, subnets, security groups
- Managed RDS / DocumentDB instances
- MSK Kafka clusters
- IAM roles & policies
- ECS / EKS deployment
- S3 buckets for object storage
- CloudWatch / X-Ray observability setup

Workflow: 

```
Terraform plan --> Terraform apply 
-> 
Privision AWS resources 
-> 
Deploy microservices to ECS/EKS 
-> 
Connect services via MSK / SQS / DynamoDB 
->
Observability pipelines (CloudWatch + X-Ray)
```


## Observability 
- Tracing: OpenTelemetry + AWS X-Ray
- Metrics: Prometheus metrics mapped to CloudWatch
- Logging: Centralized logs in CloudWatch Logs

## Local Development 
- Docker + Kind for microservices orchestration
- Local Kafka / MongoDB / Postgres for testing
- Terraform plan/apply can also point to **localstack** for AWS service emulation 


## Learning Goals 
By implementing this project, the following skills are demonstrated: 

### Cloud Native Microservices 
- CQRS / Event-driven patterns
- Saga / Outbox patterns

### AWS Integration 
- Managed services mapping
- Infrastructure as code (Terraform)

### Observability & Monitoring 
- Distributed tracing across services
- Metrics and alerting pipelines

### Platform Engineering Perspective 
- Combining local development and cloud deployment
- Scalable, idempotent operations across distributed systems 

## CI/CD Integration (Terraform + Jenkins) 
This repository also includes a **Terraform-based Jenkins CI/CD solution** on AWS to automate microservices deployment. 

- **Jenkins Master && Agents** are provisioned via Terraform (EC2/ECS/Fargate).
- **Pipeline** builds microservices Docker images, pushes to **ECR**, and deploys to **ECS/EKS**.
- **Terraform** manages both the infrastructure (VPC, IAM, RDS, S3) and pipeline configuration, ensuring a fully reproducible CI/CD environment.
- Integration with **CloudWatch & X-Ray** provides observability for deployments and runtime monotiring.

This demonstrates end-to-end automation: **local microservices** --> **AWS managed infrastructure** --> **CI/CD** --> **production-ready deployment**. 



## Future Work 
- Multi-region deployments
- CI/CD pipelines integration (GitHub Actions  / CodePipeline)
- Autoscaling & HPA / Cluster autoscaler
- Terraform modules for reusable microservice deployments 
