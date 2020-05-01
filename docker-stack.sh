#!/bin/bash

deploy () {
    echo "Create pihole_net"
    docker network create -d bridge pihole_net \
        --subnet=10.0.0.0/29

    echo "Create unbound"
    docker run -d \
        --name unbound \
        -v $(pwd)/unbound/unbound.conf:/opt/unbound/etc/unbound/unbound.conf:ro \
        --network=pihole_net --ip=10.0.0.2 \
        --restart=unless-stopped \
        mvance/unbound:1.10.0

    echo "Create pihole"
    docker run -d \
        --name pihole \
        -p 8080:80 \
        -p 8443:443 \
        -p 8053:53/tcp -p 8053:53/udp \
        -e TZ="Berlin/Europe" \
        -e DNS1="10.0.0.2#53" \
        -e DNS2="no" \
        -v $(pwd)/pihole/etc-pihole/:/etc/pihole/ \
        -v $(pwd)/pihole/etc-dnsmasq.d/:/etc/dnsmasq.d/ \
        -v $(pwd)/pihole/01-pihole.conf:/etc/.pihole/advanced/01-pihole.conf:ro \
        --dns=127.0.0.1 --dns=10.64.0.1 \
        --network=pihole_net --ip=10.0.0.3 \
        --restart=unless-stopped \
        --cap-add=NET_ADMIN \
        --link unbound \
        pihole/pihole:v4.4
}

remove () {
    echo "Stopping containers..."
    docker stop unbound pihole
    echo "Removing containers..."
    docker rm unbound pihole
    echo "Removing network..."
    docker network rm pihole_net
}

restart () {
    remove
    deploy
}

"$@"