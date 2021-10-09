#!/bin/bash

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
version: '3'
services:
  web:
      build:
        context: .
        dockerfile: ./containers/nginx/Dockerfile
      ports:
          - "$port:80"
      volumes:
        - ./nginx.conf:/etc/nginx/nginx.conf
        - ./html:/usr/share/nginx/html
      depends_on:
          - php
  php:
      build:
        context: .
        dockerfile: ./containers/php/Dockerfile
      volumes:
        - /html:/usr/share/nginx/html
EOF

}

function creat_php_config() {
    cat > $nginx_creat_name/default.conf <<EOF
server {
    index index.php index.html;
    server_name localhost;
    root /usr/share/nginx/html;

    location / {
        try_files \$uri \$uri/ /index.php\$is_args$args;
    }

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass php:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param PATH_INFO \$fastcgi_path_info;
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
    cat > $nginx_creat_name/php/docker-compser-php.yaml <<EOF
version: '2'
services:
  $php_name_random:
    tty: true # Enables debugging capabilities when attached to this container.
    image: php:$php_version
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
    docker-compose -f $nginx_creat_name/docker-compser-nginx.yaml up
}

function start_docker_php() {
    docker-compose -f $nginx_creat_name/php/docker-compser-php.yaml up -d
}

nginx_port_checker
php_port_checker
nginx_docker_name_random
php_docker_name_random
creat_nginx_docker_file
creat_php_config
creat_php_fpm_docker_file
# start_docker_php
start_docker_nginx