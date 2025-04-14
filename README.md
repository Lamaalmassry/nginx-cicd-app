# Nginx CI/CD App

This project demonstrates a complete CI/CD pipeline for deploying a Dockerized Nginx application to AWS using Terraform, GitHub Actions, and AWS EC2.

## Project Overview

The goal of this project is to create an automated pipeline for deploying a Docker-based Nginx app hosted on an EC2 instance. The pipeline leverages:
- **Terraform** for infrastructure provisioning.
- **GitHub Actions** for automating the CI/CD process.
- **Docker** for building and pushing images to Amazon ECR.

## Key Components

### 1. **Terraform Infrastructure**

Terraform is used to create the following AWS resources:
- **VPC**: A Virtual Private Cloud for networking.
- **Internet Gateway**: To allow the EC2 instance to access the internet.
- **Public Subnet**: A subnet for hosting the EC2 instance.
- **Security Group**: To allow HTTP (80) and SSH (22) access to the EC2 instance.
- **IAM Role**: An IAM role for EC2 to access ECR for pulling the Docker image.
- **ECR**: An Amazon Elastic Container Registry to store the Docker image.
- **EC2 Instance**: A t2.micro EC2 instance to host the Nginx application.

### 2. **Dockerfile**

The `Dockerfile` builds a Docker image for the Nginx application:
- **Base Image**: `nginx:alpine`
- **Build Process**: Removes default Nginx HTML and copies local files into the image.

### 3. **GitHub Actions Pipeline**

The pipeline is triggered by pushes and pull requests to the `main` branch:
- **Terraform Job**: Initializes Terraform, applies the infrastructure changes, and outputs necessary values.
- **Docker Job**: Builds and pushes the Docker image to ECR.
- **Deploy Job**: Deploys the Docker image to the EC2 instance using SSH.

## Setup

### Prerequisites

1. **AWS Account**: Ensure you have access to an AWS account and configure your AWS credentials in the GitHub repository secrets (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`).
2. **SSH Key**: Ensure you have an SSH key (`github-key`) for EC2 instance access, configured in your GitHub repository secrets.
3. **Terraform**
4. **Docker**

### Steps to Run

1. **Clone this repository**:
   ```bash
     https://github.com/Lamaalmassry/nginx-cicd-app.git
      cd nginx-cicd-app


🚀 Apply and Destroy Actions (Workflow Guide)
The CI/CD pipeline supports two primary actions via GitHub Actions workflow inputs:
  ```bash
✅ Apply
Triggers:

Automatically on push or pull_request to the main branch.

Manually by selecting apply in the Run workflow UI.

Actions:

Provisions AWS resources using terraform apply (VPC, EC2, ECR, etc.).

Builds & pushes Docker image to ECR.

Deploys the Nginx container to the EC2 instance.

Outputs EC2 public IP (e.g., http://<EC2_PUBLIC_IP>).

Condition: Runs on push/pull_request or when input is apply.

❌ Destroy
Trigger:

Manually by selecting destroy in the Run workflow UI.

Actions:

Destroys all provisioned resources using terraform destroy.

Fully cleans up the infrastructure.

Condition: Runs only when the manual input is destroy.