output "VPC-id" { # This will output the value of vpc id in terminal
  value = aws_vpc.our-vpc.id
}

output "Instance-id" { # This will output the value of instance id in terminal
  value = aws_instance.jenkins-server.id
}

output "jenkins-ip" { # This will output the value of instance public ip in terminal
  value = aws_instance.jenkins-server.public_ip
}

output "jenkins-url" {
  value = "http://${aws_instance.jenkins-server.public_ip}:8080"
}

output "nexus-url" {
  value = "http://${aws_instance.jenkins-server.public_ip}:8081"
}

output "sonarqube-url" {
  value = "http://${aws_instance.jenkins-server.public_ip}:9000"
}