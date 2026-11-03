# deploy-aws

Minimal Terraform that deploys Juice Shop on an AWS Academy Learner Lab as one EC2 instance (Amazon Linux 2023, us-east-1) running the public `bkimminich/juice-shop` Docker image. A security group allows port 3000 only from the IPs listed in `allowed_cidrs` (port 22 is opened only if you set `key_name`).

## Why not the Terraform in `terraform/`

That one is the material of a Juice Shop challenge (`iacLeakedKeyChallenge`). We reviewed it but did not run it. For a Learner Lab deployment it does not work as-is:
- it creates IAM resources (a role and a server certificate), which the Learner Lab restricts (it only provides the pre-created `LabRole`);
- it reads `certs/server.crt`, which is not in the repo;
- it points to a placeholder ECR repository (123456789012, eu-west-1) that it never creates;
- the Learner Lab only supports us-east-1 and us-west-2;
- its `local-exec` builds and pushes a Docker image from the local machine.

## Usage

Copy `terraform.tfvars.example` to `terraform.tfvars` and set your IP, then run `terraform init`, `terraform plan` and `terraform apply`. Run `terraform destroy` when done. Credentials come from the Learner Lab "AWS Details" and expire with the session.

Note: the app is intentionally vulnerable; never use `0.0.0.0/0`. It serves plain HTTP, and its data resets on each container start.
