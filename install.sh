#!/bin/bash
set -e
set -v

apt-get update
apt-get -y install ansible
echo "localhost" > /etc/ansible/hosts

cd playbook
cp vars/default-settings.yml settings.yml

ansible-playbook -c local install.yml
