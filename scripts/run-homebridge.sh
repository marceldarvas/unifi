podman run -d --restart always \
   --privileged \
   --name homebridge \
   --net homebridge \
   --dns 10.0.5.3 \
   --dns-search lan \
   -e TZ=America/Detroit \
   -e PGID=0 -e PUID=0 \
   -e HOMEBRIDGE_CONFIG_UI=1 \
   -e HOMEBRIDGE_CONFIG_UI_PORT=80 \
   -v "/mnt/data/homebridge/:/homebridge/" \
   -v "/mnt/data/homebridge/run/:/run/" \
   oznu/homebridge:latest