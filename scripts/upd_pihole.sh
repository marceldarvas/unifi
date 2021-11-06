podman pull pihole/pihole:latest
podman stop pihole
podman rm pihole
podman run -d --network dns --restart always \
--name pihole \
-e TZ="America/New York" \
-v "/mnt/data/etc-pihole/:/etc/pihole/" \
-v "/mnt/data/pihole/etc-dnsmasq.d/:/etc/dnsmasq.d/" \
--dns=127.0.0.1 \
--hostname pihole \
-e CLOUDFLARED_OPTS="--port 5053 --address 0.0.0.0" \
-e VIRTUAL_HOST="pi.hole" \
-e PROXY_LOCATION="pi.hole" \
-e ServerIP="10.0.5.3" \
-e PIHOLE_DNS_="127.0.0.1#5053" \
-e IPv6="False" \
boostchicken/pihole:latest