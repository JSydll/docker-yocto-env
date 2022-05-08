#!/bin/bash -e
# ------------------
# setup-host.sh
# 
# Sets up the necessary host tools for running the Docker-based build environment.
#
# ------------------
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# ------------------
# Script environment
# ------------------
readonly DISTRO_NAME="$(sed -n 's/^ID=//p' /etc/os-release)"
readonly DISTRO_VERSION="$(sed -n 's/^VERSION_CODENAME=//p' /etc/os-release)"

function print_help()
{
  cat <<EOF 
Syntax: ./$(basename "$0") [-h|--help]

Sets up the necessary host tools for running the Docker-based build environment.

Options:
  -h|--help             - Print this help.
EOF
}

# ----------------------
# Command line arguments
# ----------------------

while (( $# )); do
  case "$1" in
    -h|--help)
      print_help
      exit
      ;;
  esac
  shift
done

# ---------
# Functions
# ---------

function install_basic_packages()
{
  echo "> Install basic packages..."
  sudo apt update && sudo apt install -y \
    git apt-transport-https ca-certificates curl gnupg-agent software-properties-common
}

function install_docker()
{
  # Stop docker if it's already running
  sudo systemctl stop docker 
  sudo systemctl stop docker.socket
  echo "> Remove deprecated versions of Docker... "
  sudo apt remove -y docker docker-engine docker.io containerd runc
  echo "> Install and configure Docker..."
  curl -fsSL "https://download.docker.com/linux/${DISTRO_NAME}/gpg" | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/${DISTRO_NAME} ${DISTRO_VERSION} stable"
  sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose
  # Enable autostart and start docker
  sudo systemctl enable docker && \
    sudo systemctl start docker

  # Enable the current user to use docker without becoming root (if not already done)
  if ! groups | grep -c "docker" &> /dev/null; then
    usermod -aG docker ${USER}
    newgrp docker
  fi
}

# ---------
# Execution
# ---------

echo "Starting host setup..."
# Script requirements
if ! command -v apt &> /dev/null; then
  echo "This script requires the apt package manager to be installed on the system."
  exit 1
fi
if ! sudo test true &>/dev/null; then
  echo "This script requires root privileges so make sure to run this with 'sudo'"
  exit 2
fi

install_basic_packages
install_docker

echo "Done."