# AWS EKS Infrastructure with Terraform

This repository contains the **Infrastructure as Code (IaC)** required to deploy a production-ready, highly available Amazon EKS (Elastic Kubernetes Service) cluster. The setup focuses on security, automated scaling, and persistent storage using industry-standard controllers.

<!-- --- -->

<!-- ## 🏗 Architecture Diagram -->

<!-- ![EKS Architecture Diagram](https://via.placeholder.com/1000x500.png?text=VPC+EKS+Architecture+Diagram+Placeholder) -->


---

## Infrastructure Features

### 1. Networking & Foundation
* **Custom VPC:** Configured with distinct **Public and Private subnets** across multiple Availability Zones.
* **Terraform Managed:** Fully automated provisioning of cloud resources with state management.
* **IAM Hierarchy:** Dedicated **IAM Users and Roles** following the principle of least privilege for cluster administration and node execution.

### 2. High Availability & Scaling
* **Cluster Autoscaler:** Automatically adjusts the number of nodes in your cluster when pods fail to launch due to lack of resources.
* **Horizontal Pod Autoscaler (HPA):** Dynamically scales the number of pod replicas based on observed CPU/memory utilization.

### 3. Traffic Management & Security
* **AWS Load Balancer Controller:** Manages AWS Elastic Load Balancers (ALB/NLB) for Kubernetes resources.
* **NGINX Ingress Controller:** Handles Layer 7 routing and traffic splitting within the cluster.
* **Cert-Manager & TLS:** Automated issuance and renewal of SSL/TLS certificates for secure HTTPS communication.
* **AWS Secrets Manager:** Securely injects environment variables and sensitive configuration files directly into pods.

### 4. Persistent Storage
* **EKS EBS CSI Driver:** Provides block storage for stateful applications requiring high-performance disk access.
* **EKS EFS CSI Driver:** Enables shared, scalable file storage across multiple pods via Amazon Elastic File System.
* **Persistent Volume Claims (PVC):** Dynamic provisioning of storage classes for seamless developer workflows.

---

<!-- ## 📁 Repository Structure

```text
├── terraform/                # Terraform configuration files
│   ├── vpc.tf                # VPC, Subnets, and NAT Gateway
│   ├── eks.tf                # Cluster definition and Node Groups
│   ├── iam.tf                # IAM Users, Roles, and Policies
│   ├── addons.tf             # Helm releases (LB Controller, Cert-manager, etc.)
│   └── main.tf               # Providers and Backend config
├── manifests/                # Sample Kubernetes deployment manifests
└── README.md -->