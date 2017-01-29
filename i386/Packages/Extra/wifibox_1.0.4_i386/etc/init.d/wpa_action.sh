#!/bin/sh

rfkill unblock wlan
INTERFACE=$1

# For a dynamic IP with DHCP.
if [ "$2" = "CONNECTED" ]; then

	[ -f /var/run/udhcpc.$INTERFACE.pid ] && killall udhcpc

# fredx181 change, instead /etc/udhcpc/default.script read from custom script (for splash message)

	/sbin/udhcpc -b -i $INTERFACE -p /var/run/udhcpc.$INTERFACE.pid -s /etc/slitaz/wifibox_udhcpc 

elif [ "$2" = "DISCONNECTED" ]; then

# fredx181 change, instead /etc/udhcpc/default.script read from custom script (for splash message)

	/sbin/udhcpc -b -i $INTERFACE -p /var/run/udhcpc.$INTERFACE.pid -s /etc/slitaz/wifibox_udhcpc
fi

