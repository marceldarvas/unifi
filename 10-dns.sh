#!/bin/sh

## configuration variables:
VLAN=5
IPV4_IP="10.0.5.3"
IPV4_GW="10.0.5.1/24"

# IPv6 Also works with Prefix Delegation from your provider. The gateway is the
# IP of br(VLAN) and you can pick any ip address within that subnet that dhcpv6
# isn't serving
IPV6_IP=""
IPV6_GW=""

# set this to the interface(s) on which you want DNS TCP/UDP port 53 traffic
# re-routed through the DNS container. separate interfaces with spaces.
# e.g. "br0" or "br0 br1" etc.
FORCED_INTFC="br5"

# container name; e.g. nextdns, pihole, adguardhome, etc.
CONTAINER=nextdns

## network configuration and startup:
CNI_PATH=/mnt/data/podman/cni
if [ ! -f "$CNI_PATH"/macvlan ]; then
    mkdir -p $CNI_PATH
    curl -L https://github.com/containernetworking/plugins/releases/download/v0.9.0/cni-plugins-linux-arm64-v0.9.0.tgz | tar -xz -C $CNI_PATH
fi

mkdir -p /opt/cni
rm -f /opt/cni/bin
ln -s $CNI_PATH /opt/cni/bin

for file in "$CNI_PATH"/*.conflist
do
    if [ -f "$file" ]; then
        ln -s "$file" "/etc/cni/net.d/$(basename "$file")"
    fi
done

# set VLAN bridge promiscuous
ip link set br${VLAN} promisc on

# create macvlan bridge and add IPv4 IP
ip link add br${VLAN}.mac link br${VLAN} type macvlan mode bridge
ip addr add ${IPV4_GW} dev br${VLAN}.mac noprefixroute

# (optional) add IPv6 IP to VLAN bridge macvlan bridge
if [ -n "${IPV6_GW}" ]; then
  ip -6 addr add ${IPV6_GW} dev br${VLAN}.mac noprefixroute
fi

# set macvlan bridge promiscuous and bring it up
ip link set br${VLAN}.mac promisc on
ip link set br${VLAN}.mac up

# add IPv4 route to DNS container
ip route add ${IPV4_IP}/32 dev br${VLAN}.mac

# (optional) add IPv6 route to DNS container
if [ -n "${IPV6_IP}" ]; then
  ip -6 route add ${IPV6_IP}/128 dev br${VLAN}.mac
fi

# Make DNSMasq listen to the container network for split horizon or conditional forwarding
if ! grep -qxF interface=br$VLAN.mac /run/dnsmasq.conf.d/custom.conf; then
    echo interface=br$VLAN.mac >> /run/dnsmasq.conf.d/custom.conf
    kill -9 `cat /run/dnsmasq.pid`
fi

if podman container exists ${CONTAINER}; then
  podman start ${CONTAINER}
else
  logger -s -t podman-dns -p ERROR Container $CONTAINER not found, make sure you set the proper name, you can ignore this error if it is your first time setting it up
fi

# (optional) IPv4 force DNS (TCP/UDP 53) through DNS container
for intfc in ${FORCED_INTFC}; do
  if [ -d "/sys/class/net/${intfc}" ]; then
    for proto in udp tcp; do
      prerouting_rule="PREROUTING -i ${intfc} -p ${proto} ! -s ${IPV4_IP} ! -d ${IPV4_IP} --dport 53 -j DNAT --to ${IPV4_IP}"
      iptables -t nat -C ${prerouting_rule} || iptables -t nat -A ${prerouting_rule}
      
      # (optional) IPv6 force DNS (TCP/UDP 53) through DNS container
      if [ -n "${IPV6_IP}" ]; then
        prerouting_rule="PREROUTING -i ${intfc} -p ${proto} ! -s ${IPV6_IP} ! -d ${IPV6_IP} --dport 53 -j DNAT --to ${IPV6_IP}"
        ip6tables -t nat -C ${prerouting_rule} || ip6tables -t nat -A ${prerouting_rule}
      fi
    done
  fi
  done