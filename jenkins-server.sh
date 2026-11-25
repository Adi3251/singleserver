#!/bin/bash  
# this is Shebang script using /bin/bash to run commands
set -euo pipefail

################################################################################################
# Jenkins Installation
################################################################################################

sudo apt update -y  # It will update repo 
sudo apt install fontconfig openjdk-21-jre -y # It will install Openjdk

sudo java -version  # It will check java version

sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update -y
sudo apt install jenkins -y  # It will install jenkins
echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

#####################################################################################################
# Terraform Installation
#####################################################################################################

wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg

gpg --no-default-keyring \
    --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    --fingerprint

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update -y

sudo apt install terraform -y

###############################################################################################################
#                   Docker Installation
###############################################################################################################

# Add Docker's official GPG key:
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

##########################################################################################
# Other installation
##########################################################################################

usermod -aG docker jenkins
apt install unzip -y
systemctl enable --now docker

###########################################################################################
# To install AWS CLI V2
###########################################################################################
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

###########################################################################################
# To install kubectl
###########################################################################################
KUBECTL_VERSION="$(curl -fsSL https://dl.k8s.io/release/stable.txt)"
curl -fsSLO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
curl -fsSLO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

###########################################################################################
# To install maven
###########################################################################################
apt update -y
apt install maven -y

sudo systemctl restart jenkins

################################################################################################
# SonarQube and Nexus containers
################################################################################################

cat > /etc/sysctl.d/99-sonarqube.conf <<'EOF'
vm.max_map_count=524288
fs.file-max=131072
EOF
sysctl --system

docker volume create sonarqube_data
docker volume create sonarqube_extensions
docker volume create sonarqube_logs
docker volume create nexus_data

docker run -d \
  --name sonar-server \
  --restart unless-stopped \
  --memory=3g \
  --cpus=2 \
  --ulimit nofile=131072:131072 \
  --ulimit nproc=8192:8192 \
  -p 9000:9000 \
  -v sonarqube_data:/opt/sonarqube/data \
  -v sonarqube_extensions:/opt/sonarqube/extensions \
  -v sonarqube_logs:/opt/sonarqube/logs \
  sonarqube:community

docker run -d \
  --name nexus-server \
  --restart unless-stopped \
  --memory=3g \
  --cpus=2 \
  -p 8081:8081 \
  -v nexus_data:/nexus-data \
  sonatype/nexus3
