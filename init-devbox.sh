#!/usr/bin/env bash
set -euxo pipefail

# This script is responsible for setting up your devbox VM.

# Load script parameters.
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/init-devbox.env

# Install Docker daemon.
# Instructions here: https://docs.docker.com/engine/install/ubuntu/.
sudo apt-get update
sudo apt-get -y install ca-certificates curl gnupg apt-transport-https
sudo install -m 0755 -d /etc/apt/keyrings
if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
fi
sudo apt-get update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add the devbox user to the Docker group, so that sudo is not required.
usermod -a -G docker $DEVBOX_USER

# Install an OpenJDK distribution.
# Instructions here: https://adoptium.net/installation/linux/.
if [ ! -f /etc/apt/keyrings/adoptium.gpg ]; then
  curl -fsSL https://packages.adoptium.net/artifactory/api/gpg/key/public | sudo gpg --dearmor -o /etc/apt/keyrings/adoptium.gpg
  sudo chmod a+r /etc/apt/keyrings/adoptium.gpg
  echo "deb [signed-by=/etc/apt/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list
fi
sudo apt-get update
sudo apt-get -y install temurin-17-jdk

# Install yq.
sudo snap install yq

# Configure VIm.
if [ ! -f /home/$DEVBOX_USER/.vimrc ]; then
  cat <<EOF > /home/$DEVBOX_USER/.vimrc
filetype plugin indent on
syntax on
set term=xterm-256color

set ai
set et
set ts=2
set sw=2
set ruler
set cursorcolumn
EOF
fi

# Install K8s CLI.
if ! [ -f /usr/local/bin/kubectl ]; then
  rm -rf /tmp/kubectl && \
  mkdir /tmp/kubectl && \
  cd /tmp/kubectl && \
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x ./kubectl && \
  sudo install ./kubectl /usr/local/bin/kubectl && \
  echo 'source <(kubectl completion bash)' >> ~/.bashrc
fi

# Install K9s.
if [ ! -f /usr/local/bin/k9s ]; then
  rm -rf /tmp/k9s && \
  mkdir /tmp/k9s && \
  cd /tmp/k9s && \
  curl -L https://github.com/derailed/k9s/releases/download/v0.27.4/k9s_Linux_amd64.tar.gz -o k9s.tar.gz && \
  tar zxf k9s.tar.gz && \
  sudo install ./k9s /usr/local/bin/k9s && \
  echo 'export COLORTERM=truecolor' >> /home/$DEVBOX_USER/.bashrc
fi

# Install kubectx.
if [ ! -f /usr/local/bin/kubectx ]; then
  rm -rf /tmp/kubectx && \
  mkdir /tmp/kubectx && \
  cd /tmp/kubectx && \
  curl -L https://github.com/ahmetb/kubectx/releases/download/v0.9.4/kubectx_v0.9.4_linux_x86_64.tar.gz -o kubectx.tar.gz && \
  tar zxf kubectx.tar.gz && \
  sudo install kubectx /usr/local/bin/kubectx
fi

# Install Maven.
if [ ! -f /opt/apache-maven/bin/mvn ]; then
  rm -rf /opt/apache-maven && \
  rm -rf /tmp/maven && \
  mkdir /tmp/maven && \
  mkdir /opt/apache-maven && \
  cd /tmp/maven && \
  curl -L https://dlcdn.apache.org/maven/maven-3/3.9.2/binaries/apache-maven-3.9.2-bin.tar.gz -o apache-maven.tar.gz && \
  tar zxf apache-maven.tar.gz --strip-components=1 -C /opt/apache-maven && \
  echo "MAVEN_HOME=/opt/apache-maven" >> /home/$DEVBOX_USER/.bashrc && \
  echo "PATH=\$PATH:\$MAVEN_HOME/bin" >> /home/$DEVBOX_USER/.bashrc
fi
