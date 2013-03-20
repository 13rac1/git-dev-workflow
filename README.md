Git Development Workflow
========================

The Git-based Drupal website development workflow offered by Pantheon and
Acquia is easy to use, but complex to setup on your own server. If need/want a
similar dev/test/live workflow, this script will set up nearly everything.

Notes
-----
* This uses Ansible for configuration management.
* It is designed for use with Ubuntu 12.04 LTS.
* This initial version sets up dev/test/live environments for a single project
  only.
* Git clean/reset is run on every environment update. All files must either be
  in the project repository or explicitly listed in the .gitignore otherwise
  they will be deleted.
* No user should ever manually modify or create files in any of the managed
  environments.
* Run MySQLTuner: http://mysqltuner.pl/mysqltuner.pl 
* Secure your MySQL, by running *mysql_secure_installation*.


Terminology
-----------
* Drupal code - The code and binary files versioned in the git repository.
* Drupal files - The data files handled by Drupal with files table metadata.

Install
-------
1.  Create a new Ubuntu 12.04 LTS installation.
2.  Open a terminal connection as the root user.
3.  Confirm that the server is up to date. Restart after any updates:

        apt-get update
        apt-get upgrade
        reboot now

4.  Install ansible:

        apt-get -y install git python-jinja2 python-yaml python-paramiko python-software-properties python-mysqldb
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

        ansible-playbook -c local install.yml

9.  Add *dev.example.com*, *test.example.com*, *example.com*, and *www.example.com* entries
    to your local /etc/hosts file or your DNS system.
10. Add your public key and name to gitolite. (details todo)
11. Clone the project repo. (details todo)
12. Add the Drupal code to the repo and push it to update the dev environment. (details todo)
13. Import the site database. (details todo)
14. Copy all Drupal files to /var/www/PROJECT-NAME/dev/sites/default/files/ or whatever the
    Drupal public files directory is. (details todo)
15. Sync code/files/db to test and live. (details and scripts todo)
16. Done?


Todo
----
1. Optionally, use Xginx with PHP-FPM instead of Apache.
2. Optionally, use Redis instead of Memcache.
2. Add additional security.
3. Multiple projects per server.
4. Support additional software in addition to Drupal.
5. Apache optimizations.
6. MySQL optimizations.
7. Optionally, install Varnish.

Warning
-------
This automated configration comes with absolutely no warranty. Further system security
hardening is essential. You've been warned.
