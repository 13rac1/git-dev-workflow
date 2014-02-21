Git Development Workflow
========================

GDW is a group of shell scripts using Gitolite and Ansible to 
setup/maintain a Git-based Drupal production website hosting server. The 
Ansible script configures the server and all dependencies, Gitolite 
manages user access to the git repository, and a shell script automates 
the process of moving/syncing the code, public/private files, and 
database between the dev/test/live environments. The goal is to automate 
the DevOps required for a Drupal server, but to stay simple to understand 
by using standard tools.

Details
-------
There are three environments on the server: Dev/Test/Live. (Yes, this 
supports a distinct website size where everything can be on one server.) 
Each environment is a complete website including it's own copy of the 
code, public/private files, and database. Developers work on Dev. Content 
editors and site users work on Live. 

Code changes are made to Development. To push a new feature live, the 
code (from Dev) and the files/database (from Live) are brought together 
on Test, then update.php is run to perform a test. If all new features 
work as expected and nothing breaks, the new code can be pushed Live and 
update.php run again. The benefit of the Test environment is that if
something doesn't work, you are protected from breaking the Live environment.

Environments:

* Development: dev.example.com - The dev environment is used for all code 
  development. Themers/developers work with a clone of the site 
  repository. A commit pushed to the repo will automatically appear on the dev 
  environment. The dev environment is regularly updated with the live 
  database and files. New features are built and tested here.
* Testing: test.example.com - The test environment is used to test 
  changes and new functionality. 
* Live: (www.)example.com - The live environment is the actual production 
  environment for the website. Only the code is updated after the site 
  initially goes live.


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
    ssh example@domain.com gdw-drush dev en views
    # Update the test environment: test.example.com Test!
    ssh example@domain.com gdw update test
    # Update the live environment: www.example.com Test!
    ssh example@domain.com gdw update live

Notes
-----
* It is designed for use with Ubuntu 12.04 LTS. It works with a minor warning
  in Ubuntu 12.10; to be fixed.
* This initial version sets up dev/test/live environments for a single project
  only.
* Git clean/reset is run on every environment update. All files must either be
  in the project repository or explicitly listed in the .gitignore otherwise
  they will be deleted. (Currently disabled.)
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
        gdw -y db dev test
        gdw -y pull test
        gdw -y files dev test
        gdw -y db dev live
        gdw -y pull live
        gdw -y files dev live

18. Test your sites!

Create a developer user
-----------------------
1. Add user's public key to gitolite:

        cp user-public-key.pub /root/gitolite-admin/keydir/USERNAME.pub

2. Copy the PROJECT-NAME conf to create a USERNAME conf in gitolite:

        cd ~/gitolite-admin/conf/users
        cp PROJECT-NAME.conf USERNAME.conf

3. Replace the PROJECT-NAME username with USERNAME in the USERNAME.conf to add the user to the @users group:

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

Local development tips
----------------------
Clone each site from the gdw server to your www root (/var/www on Linux.)
Create databases with the same name as the project and make them accessible
to the same user. Then, you can have one gdw.settings.php file work
automatically for all local development projects.

    <?php
    /**
     * A gdw.settings.php files for local D7 development. Store in /var/www.
     */
    
    // Site is stored in '/var/www/example', so database name is 'example'
    $database = basename(getcwd());
    
    $databases = array (
      'default' => array (
        'default' => array (
          'database' => $database,
          'username' => 'root',
          'password' => 'PASSWORD',
          'host' => 'localhost',
          'port' => '',
          'driver' => 'mysql',
          'prefix' => '',
        ),
      ),
    );


Todo
----
* Optionally, use Nginx with PHP-FPM instead of Apache.
* Optionally, use Redis instead of Memcache.
* Add additional security.
* Multiple projects per server.
* Support additional software in addition to Drupal.
* Apache optimizations.
* MySQL optimizations.
* Optionally install Varnish.
* Automate the existing site import and new site creation process.
* Automate the dev user add process.
* Use factors to support CentOS.
* Fix clean/reset in the post-receive.
* Arbitrary number of environments.
* Vagrant script for local development.
* Support for load balancers.
* Support for external Redis.
* Add log of gdw commands
* Setup crontab
* Implement *curl https://raw.github.com/eosrei/git-dev-workflow/master/install.sh | bash -s*
* Allow out of order -y option on gdw script.
* Add default to -y option on gdw script.

Warning
-------
This automated configuration comes with absolutely no warranty. Further system security
hardening is essential. You've been warned!
