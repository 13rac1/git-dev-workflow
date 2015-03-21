#!/bin/bash
set -e
set -v

apt-get update
apt-get install -y python-software-properties
add-apt-repository -y ppa:rquillo/ansible

apt-get update
apt-get -y install -y ansible
echo "localhost" > /etc/ansible/hosts

cd playbook
cp vars/default-settings.yml settings.yml

ansible-playbook -c local install.yml
