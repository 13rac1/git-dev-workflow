#!/bin/bash
#    Git Development Workflow
#    Copyright (C) 2013-2016 Brad Erickson
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
