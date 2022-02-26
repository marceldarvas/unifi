podman run -d --net=host --restart always \
   --name ntopng \
   -v /mnt/data_ext/ntopng/GeoIP.conf:/etc/GeoIP.conf \
   -v /mnt/data_ext/ntopng/ntopng.conf:/etc/ntopng/ntopng.conf \
   -v /mnt/data_ext/ntopng/redis.conf:/etc/redis/redis.conf \
   -v /mnt/data_ext/ntopng/lib:/var/lib/ntopng \
   docker.io/tusc/ntopng-udm:latest