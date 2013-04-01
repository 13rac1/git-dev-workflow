Git Development Workflow
========================

The Git-based Drupal website development workflow offered by Pantheon and
Acquia is easy to use, but complex to setup on your own server. This script
will setup a similar dev/test/live workflow.

WORKFLOW DESCRIPTION
--------------------
In this workflow, there are three environments setup on the server:

* dev - The Development environment is used for all code development. As needed
  Development is updated with the current database and files from the live
  environment to keep it up to date.
* test - The Testing environment is used to test changes and new
  functionality. As needed, Testing is updated by getting the current code from
  the git repository, and the current database and files from the live
  environment.
* live - The Live environment is the actual live environment for the website.
  When tests have confirmed that the code/database/files work correctly
  on Testing, then the code is updated.

EXAMPLE USE
-----------
The following is an overly cautious example of the workflow to add module and
update the live instance from a local machine. Assumptions: The user's public
key has already been added to gitolite by the root user.

    # Get a clone of the project repository
    git clone git@domain.com:example
    # Change the directory
    cd example
    # Download Views
    drush dl views
    # Stage the Views module
    git add sites/all/modules/contrib/views
    # Commit the Views module
    git commit -m "Add the Views module"
    # Push the changes to the server, which automatically updates the
    # development environment code: dev.example.com
    git push
    # SSH to the server as the example user and update the dev environment
    # with the current live database and files.
    ssh example@domain.com gdw update dev
    # SSH to the server as the example user and run drush as the www-data user
    # to enable the views module. Test!
    ssh example@domain.com gdw-drush en views
    # Update the test environment: test.example.com Test!
    ssh example@domain.com gdw update test
    # Update the live environment: www.example.com Test!
    ssh example@domain.com gdw update live

Notes
-----
* This uses Ansible for configuration management.
* It is designed for use with Ubuntu 12.04 LTS. It works with a minor warning
  in Ubuntu 12.10; to be fixed.
* This initial version sets up dev/test/live environments for a single project
  only.
* Git clean/reset is run on every environment update. All files must either be
  in the project repository or explicitly listed in the .gitignore otherwise
  they will be deleted.
* No user should ever manually modify or create files in any of the managed
  environments.
* After the website is running, run MySQLTuner to optimize MySQL for your data set:
  http://mysqltuner.pl/mysqltuner.pl and secure MySQL by running 
  *mysql_secure_installation*.
* A Linux user with the same name as the project is created for each project.
  All site management should be done with this user.

Terminology
-----------
* Drupal code - The code and binary files versioned in the git repository.
* Drupal files - The data files handled by Drupal with files table metadata.

Install
-------
1.  Create a new Ubuntu 12.04 LTS install on a local VM or a VPS.
2.  Connect to the server via SSH and become root:

        sudo -i

3.  Confirm that the server is up to date. Restart after any updates:

        apt-get update
        apt-get upgrade
        reboot now

4.  Install ansible:

        apt-get -y install git python-jinja2 python-yaml python-paramiko python-software-properties python-mysqldb software-properties-common
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
10. Clone the project repo to /root:

        cd ~
        git clone git@localhost:example

11. Add the Drupal code to the repo, commit everything, and push it to update
    the dev environment. Adjust the .gitignore file as needed.

        cd ~/example
        git add .
        git commit -m "Initial commit"
        git push origin master

12. Create/edit the settings.php and add the database connection include to the bottom of the
    sites/default/settings.php file:

        // Added for GDW server
        if (file_exists('../gdw.settings.php')) {
          include '../gdw.settings.php';
        }

13. Force add the settings.php file to the repo, commit, and push.

        git add sites/default/settings.php -f
        git commit -m "Add GDW include to settings.php"
        git push

14. If importing a site, import the site database into the development
    environment:

        mysql PROJECT-NAME_dev < site.sql

15. If importing a site, copy/move all Drupal files to the development
    environment Drupal public files directory and be sure files are owned by
    the www-data user:

        cp -R site-files/* /var/www/PROJECT-NAME/dev/sites/default/files/
        chown -R www-data:www-data /var/www/PROJECT-NAME/dev/sites/default/files

16. If creating a new site, install Drupal by going to: http://DEV-DOMAIN.com/install.php

17. Change to the project owner and sync code/db/files from dev to test/live.

        su - PROJECT-NAME
        gdw db dev test
        gdw pull test
        gdw files dev test
        gdw db dev live
        gdw pull live
        gdw files dev live

18. Test your sites!

Create a developer user
-----------------------
1. Add user's public key to gitolite:

        cp user-public-key.pub /root/gitolite-admin/keydir/USERNAME.pub

2. Copy the PROJECT-NAME conf to create a USERNAME conf in gitolite:

        cd ~/gitolite-admin/conf/users
        cp PROJECT-NAME.conf USERNAME.conf

3. Edit the file contain the username of the user:

        nano USERNAME.conf

4. Add all changes to the repo, commit, and push:

        cd ~/gitolite-admin
        git add .
        git commit -m "Add USERNAME"
        git push

5. Add the user's public key to the PROJECT-NAME user authorized keys:

        nano /home/PROJECT-NAME/.ssh/authorized_keys

6. Test the user! From their local machine:

        git clone git@example.com:PROJECT-NAME
        ssh PROJECT-NAME@example.com gdw update dev

Todo
----
1.  Optionally, use Xginx with PHP-FPM instead of Apache.
2.  Optionally, use Redis instead of Memcache.
2.  Add additional security.
3.  Multiple projects per server.
4.  Support additional software in addition to Drupal.
5.  Apache optimizations.
6.  MySQL optimizations.
7.  Optionally install Varnish.
8.  Automate the existing site import and new site creation process.
9.  Automate the dev user add process.
10. Use factors to support CentOS.
11. Fix clean/reset in the post-receive.
12. Use rsync instead of cp for copying public files.

Warning
-------
This automated configration comes with absolutely no warranty. Further system security
hardening is essential. You've been warned.
