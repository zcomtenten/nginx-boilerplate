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
        nginx_creat_name_check=$(find ./ -name "$nginx_creat_name")
        if [ -z "$nginx_creat_name_check" ]; then
            break
        fi
    done

}

function creat_nginx_docker_file() {
    cp -r core $nginx_creat_name 
    cat > $nginx_creat_name/docker-compser.yaml <<EOF
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

function start_docker_nginx() {
    docker-compose -f $nginx_creat_name/docker-compser.yaml up
}


nginx_port_checker
nginx_docker_name_random
creat_nginx_docker_file
start_docker_nginx