#!/bin/bash
option="${1}"

case ${option} in
-v)
    if [[ ${2} != @(7.3|7.4|8.0|) ]]; then
        echo "only input 7.3 7.4 8.0"
        exit 1 # Command to come out of the program with status 1
    fi
    php_version="${2}"
    ;;
*)
    echo "input -v to version php"
    exit 1 # Command to come out of the program with status 1
    ;;
esac



function nginx_port_checker() {
    while :; do
        port=$(shuf -i 2000-4000 -n 1)
        port_checking=$(netstat -nplt | grep $port)
        port_checkingv2=$(find ./ -type f -name "*.yaml" -exec grep '$port' {} \;)
        if [ -z "$port_checking" ]; then
            if [ -z "$port_checkingv2" ]; then
                break
            fi
        fi
    done

}

function nginx_docker_name_random() {
    while :; do
        nginx_creat_name=$(openssl rand -hex 8)
        nginx_creat_name_check=$(find ./ -type f -name "*.yaml" -exec grep '$db_creat' {} \;)
        if [ -z "$nginx_creat_name_check" ]; then
            break
        fi
    done

}

function creat_nginx_docker_file() {
    cp -r core $nginx_creat_name 
    cat > $nginx_creat_name/docker-compser-nginx.yaml <<EOF
# This docker-compose.yml file is used to set up your project in the local
# development environment *only*. It is *not* used in deployment to our cloud
# servers, and has no effect whatsoever in cloud deployments.
#
# See our Developer Handbook for more information:
# http://docs.divio.com/en/latest/reference/docker-docker-compose.html
version: "2"

services:
  # The web container is an instance of exactly the same Docker image as your
  # Cloud application container.
  web:
    build: .
    # Change the port if you'd like to expose your project locally on a
    # different port, for example if you already use port 8000 for
    # something else.
    ports:
    - "$port:80"
    volumes:
      - "./nginx.conf:/etc/nginx/nginx.conf:ro"
      - "./html:/usr/share/nginx/html:ro"

EOF

}

function creat_php_config() {
    cat > $nginx_creat_name/default.conf <<EOF
server {
    listen       80;
    listen  [::]:80;
    server_name  localhost;

    #access_log  /var/log/nginx/host.access.log  main;

    location / {
        root   /usr/share/nginx/html;
        index  index.php;
    }

    #error_page  404              /404.html;

    # redirect server error pages to the static page /50x.html
    #
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
    # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
    #
    location ~ \.php$ {
        root           html;
        fastcgi_pass   127.0.0.1:$php_port;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  /scripts\$fastcgi_script_name;
        include        fastcgi_params;
    }

    # deny access to .htaccess files, if Apache's document root
    # concurs with nginx's one
    #
    location ~ /\.ht {
        deny  all;
    }
}

EOF

}

function php_port_checker() {
    while :; do
        php_port=$(shuf -i 40000-45000 -n 1)
        php_port_checking=$(netstat -nplt | grep $port)
        php_port_checkingv2=$(find ./ -type f -name "*.yaml" -exec grep '$port' {} \;)
        if [ -z "$php_port_checking" ]; then
            if [ -z "$php_port_checkingv2" ]; then
                break
            fi
        fi
    done

}

function creat_php_fpm_docker_file() {
    cat > $nginx_creat_name/docker-compser-php.yaml <<EOF
version: '2'
services:
  $php_name_random:
    tty: true # Enables debugging capabilities when attached to this container.
    image: docker.io/bitnami/php-fpm:$php_version
    ports:
      - $php_port:9000

EOF

}

function php_docker_name_random() {
    while :; do
        php_name_random=$(openssl rand -hex 8)
        php_name_random_checker=$(find ./ -type f -name "*.yaml" -exec grep '$php_name_random' {} \;)
        if [ -z "$php_name_random_checker" ]; then
            break
        fi
    done

}


function start_docker_nginx() {
    docker-compose -f $nginx_creat_name/docker-compser-nginx.yaml up -d
}

function start_docker_php() {
    docker-compose -f $nginx_creat_name/docker-compser-php.yaml up -d
}

nginx_port_checker
nginx_docker_name_random
creat_nginx_docker_file
php_port_checker
php_docker_name_random
creat_php_fpm_docker_file
creat_php_config
start_docker_php
start_docker_nginx