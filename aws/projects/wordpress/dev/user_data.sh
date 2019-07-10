#!/bin/bash

##Install WP_CLI
wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

##make this .phar file executable and move it to /usr/local/bin so that it can be run directly
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

####Activate Bash Completion - WP-CLI supports tab completion for Bash
###Download the bash script in your home directory
cd ~
wget https://github.com/wp-cli/wp-cli/raw/master/utils/wp-completion.bash

#####Edit the shell’s configuration file so that wp-completion is loaded by the shell every time you open a new shell session
echo 'source /home/$USER/wp-completion.bash' > ~/.bashrc

##Run bashrc
source ~/.bashrc

####Get wordpress Database Ready
###make the sqlscript file
cd /tmp
echo 'CREATE DATABASE wordpress;' > create_db.sql
echo 'CREATE USER 'admin' IDENTIFIED BY 'test1234';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser';
FLUSH PRIVILEGES;' > create_user.sql
echo 'quit' > exit_sql_conn.sql

##make the files executable
chmod +x create_db.sql
chmod +x create_user.sql
chmod +x exit_sql_conn.sql

###Connect to DB
sudo mysql -h $db_hostname -u admin -p test1234

Run the SQL scripts
@/tmp/create_db.sql
@/tmp/create_user.sql
@/tmp/exit_sql_conn.sql

####Download and Configure WordPress
##Move to the Apache Directory
cd /var/www/html/example.com
sudo chown -R www-data:www-data public_html

###Download Wordpress
cd public_html
sudo -u www-data wp core download
sudo -u www-data wp core config --dbname='wordpress' --dbuser='admin' --dbpass='test1234' --dbhost='$db_hostname' --dbprefix='wp_'
####Run the installation
sudo -u www-data wp core install --url='http://www.wordpress-dev.com' --title='Blog Title' --admin_user='adminuser' --admin_password='letmeinn' --admin_email='email@domain.com'
