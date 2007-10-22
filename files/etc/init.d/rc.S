#!/bin/sh

# FRITZ!Modem startup script
#
# Copyright (C) 2007 Axel Gembe <ago@bastart.eu.org>
#
# $Id: rc.S 1278 2007-09-11 11:33:48Z ago $

# Watchdog into init mode
#echo init-start 120 > /dev/watchdog

# Filesystem setup
mount -a
tar xf var.tar

# Read the configuration file
. /etc/conf.d/startup.conf

# Config file setup
echo "nameserver ${LAN_NAMESERVER}" > /etc/resolv.conf
echo "127.0.0.1 localhost" > /etc/hosts
echo "${LAN_HOSTS}" >> /etc/hosts

# Network + ATM bridging setup
modprobe tiatm atm_strict_prio=1 firmware_load_file=/lib/modules/microvoip-dsl.bin annex=${DSL_ANNEX} ptest=0
br2684ctl -b -c 0 -a ${DSL_VPI}.${DSL_VCI}
ifconfig lo 127.0.0.1
ifconfig cpmac0 up
ifconfig nas0 up
brctl addbr br0
brctl addif br0 cpmac0
brctl addif br0 nas0
ifconfig br0 ${LAN_IPADDR} netmask ${LAN_NETMASK}
route add default gw ${LAN_GATEWAY}

# Server startup
telnetd -l /bin/sh
telnetd -p ${SYS_SIGVAL_PORT} -l /var/sigvals.sh

# Watchdog into normal mode
#echo init-done > /dev/watchdog
