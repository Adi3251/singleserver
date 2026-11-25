# Jenkins, SonarQube, and Nexus on One Server

This project provisions one EC2 instance in AWS and configures Jenkins, SonarQube, and Nexus on it. It uses `m7i-flex.large` with a 30 GB root volume.

**Cost and resource warning:** `m7i-flex.large` is not Free Tier eligible and incurs charges. Its resources may still be tight for Jenkins, SonarQube, and Nexus running at the same time, especially during builds or analysis.

## Run the code

Configure AWS credentials and ensure the EC2 key pair named `jenkins` exists in `ap-south-1`. From this directory, run:

```sh
terraform init
terraform validate
terraform plan
terraform apply
```

Terraform outputs the service URLs after deployment:

- Jenkins: port `8080`
- Nexus: port `8081`
- SonarQube: port `9000`

The first boot installs the services and starts the containers; allow several minutes for initialization. Docker volumes preserve Nexus and SonarQube data if their containers restart.

Applying this configuration removes the separately managed Nexus and SonarQube EC2 instances and runs those services on the Jenkins EC2 instance instead. The Jenkins instance can also be replaced to run the updated startup script. Back up any Jenkins, Nexus, or SonarQube data you need to keep, and review `terraform plan` before applying.

Use `terraform destroy` to remove the resources created by this code.
