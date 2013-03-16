Git Development Workflow
========================

The Git-based website development workflow offered by Pantheon and Acquia is easy to use,
but complex to setup on your own server. If need/want a similar dev/test/live workflow,
this script will set up nearly everything.

Notes
----
This uses Ansible for configuration management and is designed for use with
Ubuntu 12.04 LTS.

The initial version of this script sets up dev/test/live environments for a single project
only. Multiple projects per server are a todo.

Install
-------
1.  Create a new Ubuntu 12.04 LTS installation.
2.  Open a terminal connection as the root user.
3.  Confirm that the server is up to date. Restart after any updates:

        apt-get update
        apt-get upgrade
        reboot now

4.  Install ansible:

        apt-get -y install git python-jinja2 python-yaml python-paramiko python-software-properties
        add-apt-repository -y ppa:rquillo/ansible/ubuntu
        apt-get update
        apt-get -y install ansible
        echo "localhost" > /etc/ansible/hosts

5.  Clone the git-dev-workflow repo:

        git clone https://github.com/eosrei/git-dev-workflow.git ~/git-dev-workflow

6.  Copy the default settings file:

        cd ~/git-dev-workflow/playbook
        cp vars/default-settings.yml ./settings.yml

7.  Edit the *settings.yml* file and adjust for your project/environment:

        nano settings.yml

8.  Save and close the settings file, then run the Ansible playbook:

        ansible-playbook -c local setup.yml

9.  Add *dev.example.com*, *test.example.com*, *example.com*, and *www.example.com* entries
    to your local /etc/hosts file or your DNS system.
10. Done?


Todo
----
1. Use Xginx with PHP-FPM.
2. Add additional security
