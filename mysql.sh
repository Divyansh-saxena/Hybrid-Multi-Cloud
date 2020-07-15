#! /bin/bash
sudo yum update -y
sudo yum install docker -y
sudo service docker start
echo MYSQL_ROOT_PASSWORD = RootPass > my-env.txt
echo MYSQL_DATABASE = mysqlDB >> my-env.txt
echo MYSQL_USER = mysqlUser >> my-env.txt
echo MYSQL_PASSWORD = mysqlPass >> my-env.txt
sudo docker run -dit -p 8080:3306 --env-file my-env.txt mysql:5.6