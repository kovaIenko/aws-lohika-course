#!/bin/bash
sudo yum update -y
sudo yum install java-1.8.0-openjdk -y
sudo yum install httpd -y
sudo service httpd start
sudo chkconfig httpd on
cd /var/www/html
echo "<html><h1>This is WebServer from private subnet</h1></html>" > index.html
