#!/bin/bash
echo "=== apt-get update ==="
sudo apt-get update

echo "=== Installing all required packages ==="
sudo apt-get install apache2 php php-pgsql php-json postgresql php7.0-xml php-mbstring phpunit php-zip git -y

echo "=== Configuring Apache2 ==="
#TODO : HTTPS config
sudo cp /vagrant/confs/apache_dev_inspicio.conf /etc/apache2/sites-enabled/dev_inspicio.conf
#TODO : Change apache user to be vagrant
sudo a2enmod rewrite
sudo service apache2 restart

echo "=== Configuring PostgreSQL ==="
#TODO : Dynamic passwords ?
sudo -u postgres psql -c "CREATE USER inspicio_dev;"
sudo -u postgres psql -c "ALTER ROLE inspicio_dev WITH CREATEDB;"
sudo -u postgres psql -c "CREATE DATABASE inspicio_db_dev OWNER inspicio_dev;"
sudo -u postgres psql -c "ALTER USER inspicio_dev WITH ENCRYPTED PASSWORD 'inspicio_dev_password'"
#sudo sed -i 's/peer/md5/' /etc/postgresql/9.3/main/pg_hba.conf
sudo /etc/init.d/postgresql restart

echo "=== Installing Composer ==="
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
sudo php composer-setup.php --install-dir=/bin --filename=composer
php -r "unlink('composer-setup.php');"


echo "=== Setting up Inspicio ==="
cd /var/www/html/ && git clone https://github.com/apcros/Inspicio.git
cd /var/www/html/Inspicio
cp /vagrant/confs/env_inspicio_dev.env .env
composer install
php artisan key:generate
#TODO : Start the queue ?
#TODO : Copy the env script

sudo ln -s /var/www/html/ /vagrant/vm-www-dir