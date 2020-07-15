#! /bin/bash
sudo yum update -y
sudo yum install docker -y
sudo service docker start
echo WORDPRESS_DB_HOST = mysqlDB > my-env.txt
echo WORDPRESS_DB_PASSWORD = mysqlPass >> my-env.txt
sudo docker run -dit -p 80:80 --env-file my-env.txt wordpress:4.8-apache
