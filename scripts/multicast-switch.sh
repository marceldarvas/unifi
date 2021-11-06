#!/bin/sh

# kill all instances of avahi-daemon (UDM spins an instance up even with mDNS services disabled)
killall avahi-daemon

# start the multicast-relay container image
podman start multicast-relay