#!/bin/bash

function install_packages ()
{
  echo "Install Nginx"
echo $pwd 
sudo apt update 
sudo apt install nginx -y 
echo "Setup configs..."
export HOSTNAME=$(hostname | tr -d '\n')
export PRIVATE_IP=$(curl -sf -H 'Metadata-Flavor:Google' http://metadata/computeMetadata/v1/instance/network-interfaces/0/ip | tr -d '\n')
echo "Welcome to $HOSTNAME - $PRIVATE_IP" > index.html
head -c 1KB /dev/urandom > 1kb.txt
head -c 10KB /dev/urandom > 10kb.txt
head -c 100KB /dev/urandom > 100kb.txt
sudo mv *.txt /var/www/html/
sudo mv index.html /var/www/html/
sudo service nginx restart

  sleep 5

}

### script begins here ###

install_packages

echo "Done"
exit 0