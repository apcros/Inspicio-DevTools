#!/bin/bash
echo "=== apt-get update ==="
sudo apt-get update

echo "=== Installing all required packages ==="
sudo apt-get install apache2 php php-pgsql php-json postgresql php7.0-xml php-mbstring phpunit php-zip php-curl git -y

echo "=== Configuring Apache2 ==="
sudo cp /vagrant/confs/apache_dev_inspicio.conf /etc/apache2/sites-enabled/dev_inspicio.conf
sudo rm /etc/apache2/envvars
sudo cp /vagrant/confs/apache_dev_inspicio.envvars /etc/apache2/envvars
sudo chown -R ubuntu:ubuntu /var/www/
sudo sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
sudo a2enmod rewrite
sudo a2enmod ssl
sudo service apache2 restart

echo "=== Configuring PostgreSQL ==="
#TODO : Dynamic passwords ?
sudo -u postgres psql -c "CREATE USER inspicio_dev;"
sudo -u postgres psql -c "ALTER ROLE inspicio_dev WITH CREATEDB;"
sudo -u postgres psql -c "CREATE DATABASE inspicio_db_dev OWNER inspicio_dev;"
sudo -u postgres psql -c "ALTER USER inspicio_dev WITH ENCRYPTED PASSWORD 'inspicio_dev_password'"
sudo sed -i 's/peer/md5/' /etc/postgresql/*/main/pg_hba.conf
sudo /etc/init.d/postgresql restart

echo "=== Installing Composer ==="
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
sudo php composer-setup.php --install-dir=/bin --filename=composer
php -r "unlink('composer-setup.php');"


echo "=== Setting up Inspicio ==="
cd /vagrant/ && mkdir vm-www-dir
cd /vagrant/vm-www-dir
git clone https://github.com/apcros/Inspicio.git
sudo chown -R ubuntu:ubuntu /var/www/
cd /vagrant/vm-www-dir/Inspicio
cp /vagrant/confs/env_inspicio_dev.env .env

composer install
php artisan key:generate
php artisan migrate
sudo rm -rf /var/www/html
sudo ln -s /vagrant/vm-www-dir /var/www/html
sudo service apache2 restart