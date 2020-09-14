#!/bin/sh

set -e

# cleanup old udm-boot container
if /usr/bin/podman container exists udm-boot; then
	/usr/bin/podman rm --force --volumes udm-boot
fi
if [ -f /run/udm-boot.service-cid ]; then
	rm -v /run/udm-boot.service-cid
fi
if [ -f /run/udm-boot.service-pid ]; then
	rm -v /run/udm-boot.service-pid
fi

# purge images and volumes
if [ "$1" = "purge" ]; then
	if /usr/bin/podman image exists udm-boot; then
		/usr/bin/podman image rm udm-boot
	fi
fi


