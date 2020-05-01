FROM pihole/pihole:latest
RUN sudo apt-get update && sudo apt-get -y install unbound
RUN wget -O root.hints https://www.internic.net/domain/named.root && \
    sudo mv root.hints /var/lib/unbound/
COPY pi-hole.conf /etc/unbound/unbound.conf.d/pi-hole.conf
RUN sudo service unbound start
RUN sed -i "s/cache-size=.*/cache-size=0/g" /etc/dnsmasq.d/01-pihole.conf