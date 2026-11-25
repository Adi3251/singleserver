# singleserver

This project creates Jenkins, Nexus, and SonarQube infrastructure in AWS using Terraform.

## Run the code

Create an S3 bucket with a unique name and update `backend.tf` with that bucket name.

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

Use `terraform destroy` to remove the resources created by this code.
