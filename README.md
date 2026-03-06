# 🚀 AWS Infrastructure Automation & DevSecOps Lab

[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=dcanosu_aws-lab&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=YOUR_PROJECT_ID)
[![Terraform Security](https://img.shields.io/badge/Security-tfsec-orange)](https://github.com/aquasecurity/tfsec)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This repository demonstrates a production-grade **Infrastructure as Code (IaC)** and **DevSecOps** workflow. It automates the deployment of a scalable AWS architecture using Terraform, Ansible, and GitHub Actions, with a strong focus on centralized secret management and code quality.

## 🏗️ Architecture Overview
The solution deploys a highly available web environment including:
* **Networking:** Custom VPC with Public/Private subnets across multiple AZs.
* **Compute:** Auto Scaling Group (ASG) of EC2 instances.
* **Load Balancing:** Application Load Balancer (ALB) for traffic distribution.
* **Storage:** Remote Terraform State management via Amazon S3 and DynamoDB for state locking.
* **Observability:** CloudWatch Dashboards and Logs integration.

---

## 🛠️ Tech Stack
* **IaC:** Terraform
* **Configuration Management:** Ansible
* **CI/CD:** GitHub Actions
* **Secret Management:** AWS Secrets Manager
* **Security & Quality:** SonarQube (SonarCloud) & IAM Least Privilege
* **Cloud Provider:** Amazon Web Services (AWS)

---

## 🔒 Security Best Practices (DevSecOps)

### 1. Centralized Secret Management
To prevent secret sprawl, sensitive tokens (SonarCloud & GitHub SCM Access) are **not stored** in GitHub Secrets. Instead:
* They are dynamically retrieved from **AWS Secrets Manager** during CI/CD runtime.
* Access is controlled via fine-grained IAM Policies scoped to specific ARNs.

### 2. Automated Quality Gates
The CI pipeline implements a **Shift-Left Security** approach:
* **SonarCloud Scan:** Mandatory analysis on every Pull Request.
* **Branch Protection:** Merging to `main` is blocked unless the Quality Gate passes.
* **Static Analysis:** Continuous monitoring for code smells and vulnerabilities.

---

## 📂 Project Structure
```text
├── .github/workflows   # CI/CD pipelines (Validation & Deployment)
├── ansible/            # Software configuration playbooks
├── terraform/          
│   ├── modules/        # Reusable components (VPC, ALB, ASG, IAM)
│   ├── backend/        # S3/DynamoDB bootstrapping
│   └── main.tf         # Root module
├── terraform-policy.json # IAM Policy as Code for the CI/CD user
└── README.md