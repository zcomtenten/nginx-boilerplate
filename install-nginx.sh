#!/bin/bash
function port_checker() {
    while :; do
        port=$(shuf -i 45000-50000 -n 1)
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
        db_creat=$(openssl rand -hex 8)
        db=$(find ./ -type f -name "*.yaml" -exec grep '$db_creat' {} \;)
        if [ -z "$db" ]; then
            break
        fi
    done

}

function creat_nginx_docker_file() {
    cp -r core $db_creat 
    cat > $db_creat/docker-compser-$db_creat.yaml <<EOF
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

function start_docker() {
    docker_compose -f $db_creat/docker-compser-$db_creat.yaml up -d
}


port_checker
nginx_docker_name_random
creat_nginx_docker_file
start_docker