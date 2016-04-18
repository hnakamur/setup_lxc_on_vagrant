#!/bin/sh
set -x
set -eu

unsupported_distrib_release() {
  echo 'This script supports only Ubuntu 14.04 and 16.04'
  exit 2
}

check_distrib_release() {
  [ -f /etc/lsb-release ] || unsupported_distrib_release
  . /etc/lsb-release
  [ "$DISTRIB_ID" = "Ubuntu" ] || unsupported_distrib_release
  [ "$DISTRIB_RELEASE" = "14.04" -o "$DISTRIB_RELEASE" = "16.04" ] || unsupported_distrib_release
}

install_lxc_on_trusty() {
  apt-add-repository -y ppa:ubuntu-lxc/lxc-stable
  apt-get update
  apt-get install -y lxc
}

install_lxc_on_xenial() {
  apt-get update
  apt-get install -y lxc
}

install_lxc() {
  case $DISTRIB_RELEASE in
  14.04)
    install_lxc_on_trusty
    ;;
  16.04)
    install_lxc_on_xenial
    ;;
  esac
}

modify_dhclient_conf() {
  if ! grep -q '^prepend domain-name-servers '$LXC_ADDR'$' /etc/dhcp/dhclient.conf; then
    sed -i '/^#prepend domain-name-servers 127.0.0.1;$/a\
prepend domain-name-servers '$LXC_ADDR';
' /etc/dhcp/dhclient.conf
  fi
}

use_lxc_dnsmasq_to_resolv_container_names() {
  sed -i 's/^#LXC_DOMAIN="lxc"/LXC_DOMAIN="lxc"/' /etc/default/lxc-net

  modify_dhclient_conf
}

let_lxc_dnsmasq_to_use_dhcp_hosts_file() {
  touch /etc/lxc/dnsmasq-hosts.conf
  echo 'dhcp-hostsfile=/etc/lxc/dnsmasq-hosts.conf' > /etc/lxc/dnsmasq.conf
  sed -i 's|^#LXC_DHCP_CONFILE=/etc/lxc/dnsmasq.conf|LXC_DHCP_CONFILE=/etc/lxc/dnsmasq.conf|' /etc/default/lxc-net
  service lxc-net restart
}

check_distrib_release
install_lxc
. /etc/default/lxc-net
use_lxc_dnsmasq_to_resolv_container_names
let_lxc_dnsmasq_to_use_dhcp_hosts_file

if [ "$DISTRIB_RELEASE" = "16.04" ]; then
  service lxc-net restart
  service networking restart
fi
