 podman run -d -it --privileged --network dns --restart always  \
    --name nextdns \
    -v "/mnt/data/nextdns/:/etc/nextdns/" \
    -v /var/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket \
    --mount type=bind,source=/config/dnsmasq.lease,target=/tmp/dnsmasq.leases \
    --dns=45.90.28.88 --dns=45.90.30.88 \
    --hostname nextdns \
    boostchicken/nextdns-udm:latest