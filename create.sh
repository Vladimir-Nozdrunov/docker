#!/usr/bin/env bash

rm -rf .git/

ENV_FILE=".env"

sudo cp .env.example $ENV_FILE
chmod 755 $ENV_FILE

BLUE=$(printf "\033[1;34m")
YELLOW=$(printf "\033[1;33m")
GREEN=$(printf "\033[0;32m")
WHITE=$(printf "\033[0m")

APP_NAME_CHANGED_STRING="APPNAME"
SQL_DB_NAME_CHANGED_STRING="DATABASE_NAME"
SQL_ROOT_PASSWORD_CHANGED_STRING="PASSWORD_FOR_ROOT"
SQL_USER_CHANGED_STRING="USER_SQL"
SQL_PASSWORD_CHANGED_STRING="PASSWORD_SQL"

VIRTUAL_HOST_FILE="nginx/sites/site.conf"

JARVIS="jarvis.sh"

echo -e "\n"
echo -e $YELLOW "Hello, let me help you to configure your Docker environment:" $WHITE "\n"
echo -e $WHITE "During the configuration you will asked your for a root password for next goals: \n
 - Create .env file with your app config
 - Modify site.conf with your domain name
 - Configure helper named Jarvis for start/stop Docker and executing php, mysql, composer and some common Symfony commands
 - Remove .git folder inside Docker folder to prevent accidental hit of environment files into commits" $WHITE "\n"
echo -e $BLUE "What is the name of your project?" $WHITE "\n"

read appname
sed -i "s/$APP_NAME_CHANGED_STRING/$appname/" $ENV_FILE

DOMAIN_NAME="${appname}.loc"
sed -i "s/$APP_NAME_CHANGED_STRING/$DOMAIN_NAME/" $VIRTUAL_HOST_FILE

echo -e $BLUE "What about SQL ROOT password?" $WHITE "\n"
read root_pass
sed -i "s/$SQL_ROOT_PASSWORD_CHANGED_STRING/$root_pass/" $ENV_FILE

echo -e $BLUE "DATABASE name?" $WHITE "\n"
read db_name
sed -i "s/$SQL_DB_NAME_CHANGED_STRING/$db_name/" $ENV_FILE

echo -e $BLUE "DATABASE user?" $WHITE "\n"
read db_user
sed -i "s/$SQL_USER_CHANGED_STRING/$db_user/" $ENV_FILE

echo -e $BLUE "PASSWORD for ${db_user}?" $WHITE "\n"
read db_user_pass
sed -i "s/$SQL_PASSWORD_CHANGED_STRING/$db_user_pass/" $ENV_FILE

NGINX_CONTAINER_NAME="${appname}_nginx"
MYSQL_CONTAINER_NAME="${appname}_mysql"
PHP_CONTAINER_NAME="${appname}_php-fpm"

sudo cp jarvis.example $JARVIS
chmod 755 $JARVIS

sed -i "s/NGINX_CONTAINER_NAME/${NGINX_CONTAINER_NAME}/" $JARVIS
sed -i "s/PHP_CONTAINER_NAME/${PHP_CONTAINER_NAME}/" $JARVIS
sed -i "s/MYSQL_CONTAINER_NAME/$MYSQL_CONTAINER_NAME/" $JARVIS
sed -i "s/USER_MYSQL_NAME/$db_user/" $JARVIS
sed -i "s/ROOT_PASSWORD_MYSQL/$root_pass/" $JARVIS

mv $JARVIS ../

echo -e $GREEN "Congratulation! Your docker environment is ready." $WHITE "\n"
echo -e $BLUE "Now to add your domain ${WHITE}'${DOMAIN_NAME}'${BLUE} to /etc/hosts file !!" $WHITE "\n"
echo -e $YELLOW "You can run your environment immediately by typing 'build' or run it manually by executing: './jarvis.sh start' in root of your project" $WHITE "\n"

read build
if [ "$build" == "build" ]; then
  docker-compose up -d --build --remove-orphans;
  else
  exit
fi