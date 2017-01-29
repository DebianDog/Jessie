#!/bin/bash
#
# /etc/init.d/network.sh : Network initialization boot script
# /etc/network.conf      : Main SliTaz network configuration file
# /etc/wpa/wpa.conf      : Wi-Fi networks configuration file

. /etc/init.d/rc.functions

CONF="${2:-/etc/network.conf}"
echo "Loading network settings from $CONF"
. "$CONF"

WPA_CONF='/etc/wpa/wpa.conf'
[ ! -e "$WPA_CONF" ] && cp /etc/wpa/wpa_empty.conf $WPA_CONF 2> /dev/null

# Migrate existing settings to a new format file

. /usr/share/slitaz/network.conf_migration


# Actions executing on boot time (running network.sh without parameters)

boot() {
	# Set hostname
	action "Setting hostname to: $(cat /etc/hostname)"
	/bin/hostname -F /etc/hostname
	status

	# Configure loopback interface
	action 'Configuring loopback...'
	/sbin/ifconfig lo 127.0.0.1 up
	/sbin/route add -net 127.0.0.0 netmask 255.0.0.0 dev lo
	status

	[ -s /etc/sysctl.conf ] && sysctl -p /etc/sysctl.conf
}


# Use ethernet

eth() {
	[ "$WIFI" != 'yes' ] && ifconfig $INTERFACE up && sleep 5
}


# Start wpa_supplicant with prepared settings in wpa.conf

start_wpa_supplicant() {
	echo "Starting wpa_supplicant for $1..."
	wpa_supplicant -B -W -c$WPA_CONF -D$WIFI_WPA_DRIVER -i$WIFI_INTERFACE
}


# Reconnect to the given network

reconnect_wifi_network() {
	if [ "$WIFI" == 'yes' ]; then
		# Wpa_supplicant will auto-connect to the first network
		# notwithstanding to priority when scan_ssid=1
		current_ssid="$(wpa_cli list_networks 2>/dev/null | fgrep '[CURRENT]' | cut -f2)"
		if [ "$current_ssid" != "$WIFI_ESSID" ]; then
			action 'Connecting to $WIFI_ESSID...'
			for i in $(seq 5); do
				index=$(wpa_cli list_networks 2>/dev/null | \
					grep -m1 -F $'\t'$WIFI_ESSID$'\t' | head -n1 | cut -f1)
				[ -z "$index" ] && echo -n '.' && sleep 1
			done
			wpa_cli select_network $index >/dev/null; status
		fi
	fi
}


# Remove selected network settings from wpa.conf

remove_network() {
	mv -f $WPA_CONF $WPA_CONF.old
	cat $WPA_CONF.old | tr '\n' '\a' | sed 's|[^#]\(network={\)|\n\1|g' | \
		fgrep -v "ssid=\"$1\"" | tr '\a' '\n' > $WPA_CONF
}


# For Wi-Fi. Users just have to enable it through WIFI="yes" and usually
# ESSID="any" will work and the interface is autodetected.

wifi() {
	if [ "$WIFI" == 'yes' ]; then
		ifconfig $INTERFACE down

		# Confirm if $WIFI_INTERFACE is the Wi-Fi interface
		if [ ! -d /sys/class/net/$WIFI_INTERFACE/wireless ]; then
			echo "$WIFI_INTERFACE is not a Wi-Fi interface, changing it."
			WIFI_INTERFACE=$(iwconfig 2>/dev/null | awk 'NR==1{print $1}')
			[ -n "$WIFI_INTERFACE" ] && sed -i \
				"s|^WIFI_INTERFACE=.*|WIFI_INTERFACE=\"$WIFI_INTERFACE\"|" \
				/etc/network.conf
		fi

		action 'Configuring Wi-Fi interface $WIFI_INTERFACE...'
		ifconfig $WIFI_INTERFACE up 2>/dev/null
	ret=$?
	echo ret=$ret
	if [ $ret -ne 0 ]; then
	export NOWIFI="yes"
	sed -i \
		-e s'/^WIFI=.*/WIFI="no"/' \
		/etc/network.conf
	return
	fi
		if iwconfig $WIFI_INTERFACE | fgrep -q 'Tx-Power'; then
			iwconfig $WIFI_INTERFACE txpower on
		fi
		status

		IWCONFIG_ARGS=''
		[ -n "$WIFI_WPA_DRIVER" ] || WIFI_WPA_DRIVER='wext'
		[ -n "$WIFI_MODE" ]    && IWCONFIG_ARGS="$IWCONFIG_ARGS mode $WIFI_MODE"
		[ -n "$WIFI_CHANNEL" ] && IWCONFIG_ARGS="$IWCONFIG_ARGS channel $WIFI_CHANNEL"
		[ -n "$WIFI_AP" ]      && IWCONFIG_ARGS="$IWCONFIG_ARGS ap $WIFI_AP"

		# Use "any" network only when it is needed
		[ "$WIFI_ESSID" != 'any' ] && remove_network 'any'

		# Clean all / add / change stored networks settings
		if [ "$WIFI_BLANK_NETWORKS" == 'yes' ]; then
			echo "Creating new $WPA_CONF"
			cat /etc/wpa/wpa_empty.conf > $WPA_CONF
		else
			if fgrep -q ssid=\"$WIFI_ESSID\" $WPA_CONF; then
				echo "Change network settings in $WPA_CONF"
				# Remove given existing network (it's to be appended later)
				remove_network "$WIFI_ESSID"
			else
				echo "Append existing $WPA_CONF"
			fi
		fi

		# Each new network has a higher priority than the existing
		MAX_PRIORITY=$(sed -n 's|[\t ]*priority=\([0-9]*\)|\1|p' $WPA_CONF | sort -g | tail -n1)
		PRIORITY=$(( ${MAX_PRIORITY:-0} + 1 ))

		# Begin network description
		cat >> $WPA_CONF <<EOT
network={
	ssid="$WIFI_ESSID"
EOT

		# For networks with hidden SSID: write its BSSID
		[ -n "$WIFI_BSSID" ] && cat >> $WPA_CONF <<EOT
	bssid=$WIFI_BSSID
EOT
		# Allow probe requests (for all networks)
		cat >> $WPA_CONF <<EOT
	scan_ssid=1
EOT

		case x$(echo -n $WIFI_KEY_TYPE | tr a-z A-Z) in
			x|xNONE) # Open network
				cat >> $WPA_CONF <<EOT
	key_mgmt=NONE
	priority=$PRIORITY
}
EOT
				# start_wpa_supplicant NONE
				iwconfig $WIFI_INTERFACE essid "$WIFI_ESSID" $IWCONFIG_ARGS
				;;

			xWEP) # WEP security
				# Encryption key length:  64 bit  (5 ASCII or 10 HEX)
				# Encryption key length: 128 bit (13 ASCII or 26 HEX)
				# ASCII key in "quotes", HEX key without quotes
				case "${#WIFI_KEY}" in
					10|26) Q=''  ;;
					*)     Q='"' ;;
				esac
				cat >> $WPA_CONF <<EOT
	key_mgmt=NONE
	auth_alg=OPEN SHARED
	wep_key0=$Q$WIFI_KEY$Q
	priority=$PRIORITY
}
EOT
				start_wpa_supplicant WEP ;;

			xWPA) # WPA/WPA2-PSK security
	# fredx181 wifi-box creates encrypted psk in this version, so remove quotes around $WIFI_KEY here,
	# otherwise wpa_supplicant complains about more than 64 chars
				cat >> $WPA_CONF <<EOT
	psk=$WIFI_KEY
	key_mgmt=WPA-PSK
	priority=$PRIORITY
}
EOT
				start_wpa_supplicant WPA/WPA2-PSK ;;

			xEAP) # 802.1x EAP security
				{
					cat <<EOT
	key_mgmt=WPA-EAP IEEE8021X
	eap=$WIFI_EAP_METHOD
EOT
					if [ "$WIFI_EAP_METHOD" == 'PWD' ]; then
						WIFI_PHASE2=''; WIFI_CA_CERT=''; WIFI_USER_CERT=''; WIFI_ANONYMOUS_IDENTITY=''
					fi
					[ -n "$WIFI_CA_CERT" ] && echo -e "\tca_cert=\"$WIFI_CA_CERT\""
					[ -n "$WIFI_CLIENT_CERT" ] && echo -e "\tclient_cert=\"$WIFI_CLIENT_CERT\""
					[ -n "$WIFI_IDENTITY" ] && echo -e "\tidentity=\"$WIFI_IDENTITY\""
					[ -n "$WIFI_ANONYMOUS_IDENTITY" ] && echo -e "\tanonymous_identity=\"$WIFI_ANONYMOUS_IDENTITY\""
					[ -n "$WIFI_KEY" ] && echo -e "\tpassword=\"$WIFI-KEY\""
					[ -n "$WIFI_PHASE2" ] && echo -e "\tphase2=\"auth=$WIFI_PHASE2\""
					echo }
				} >> $WPA_CONF
				start_wpa_supplicant '802.1x EAP' ;;

			xANY)
	# fredx181 remove quotes for $WIFI_KEY, otherwise wpa_supplicant complains about more than 64 chars
				cat >> $WPA_CONF <<EOT
	key_mgmt=WPA-EAP WPA-PSK IEEE8021X NONE
	group=CCMP TKIP WEP104 WEP40
	pairwise=CCMP TKIP
	psk=$WIFI_KEY
	password="$WIFI_KEY"
	priority=$PRIORITY
}
EOT
				start_wpa_supplicant 'any key type' ;;

		esac
		INTERFACE=$WIFI_INTERFACE
	else # fredx181 check for the right Wi-Fi interface also when WIFI is not set to yes
		if [ ! -d /sys/class/net/$WIFI_INTERFACE/wireless ]; then
			echo "$WIFI_INTERFACE is not a Wi-Fi interface, changing it."
			WIFI_INTERFACE=$(iwconfig 2>/dev/null | awk 'NR==1{print $1}')
			[ -n "$WIFI_INTERFACE" ] && sed -i \
				"s|^WIFI_INTERFACE=.*|WIFI_INTERFACE=\"$WIFI_INTERFACE\"|" \
				/etc/network.conf
		fi
	fi
}


# WPA DHCP script

wpa() {
# fredx181, remove files created from /etc/slitaz/wifibox_udhcpc
rm -f /tmp/no_fail_message    # created from /etc/slitaz/wifibox_udhcpc script
rm -f /tmp/no_connect_message   # created from /etc/slitaz/wifibox_udhcpc script

	wpa_cli -a"/etc/init.d/wpa_action.sh" -B
}


# For a dynamic IP with DHCP

dhcp() {
. "$CONF"
	if [ "$DHCP" == 'yes' ]; then
		echo "Starting udhcpc client on: $INTERFACE..."
		# Is wpa wireless && wpa_ctrl_open interface up?
		if [ -d /var/run/wpa_supplicant ] && [ "$WIFI" == 'yes' ]; then
			wpa
		else
			# fallback on udhcpc: wep, eth
# fredx181 change, instead /etc/udhcpc/default.script read from custom script (for splash messages)
rm -f /tmp/no_fail_message    # created from /etc/slitaz/wifibox_udhcpc script
rm -f /tmp/no_connect_message   # created from /etc/slitaz/wifibox_udhcpc script
/sbin/udhcpc -b -T 1 -A 12 -i $INTERFACE -p /var/run/udhcpc.$INTERFACE.pid -s /etc/slitaz/wifibox_udhcpc &
		fi
	fi
}


# For a static IP

static_ip() {
	if [ "$STATIC" == 'yes' ]; then
		echo "Configuring static IP on $INTERFACE: $IP..."
		if [ -n "$BROADCAST" ]; then
			/sbin/ifconfig $INTERFACE $IP netmask $NETMASK broadcast $BROADCAST up
		else
			/sbin/ifconfig $INTERFACE $IP netmask $NETMASK up
		fi

		# Use ip to set gateways if iproute.conf exists
		if [ -f /etc/iproute.conf ]; then
			while read line; do
				ip route add $line
			done < /etc/iproute.conf
		else
			/sbin/route add default gateway $GATEWAY
		fi

		# wpa_supplicant waits for wpa_cli
		[ -d /var/run/wpa_supplicant ] && wpa_cli -B

		# Multi-DNS server in $DNS_SERVER
		/bin/mv /etc/resolv.conf /tmp/resolv.conf.$$
		{
			printf 'nameserver %s\n' $DNS_SERVER			# Multiple allowed
			[ -n "$DOMAIN" ] && echo "search $DOMAIN"
		} >> /etc/resolv.conf
		for HELPER in /etc/ipup.d/*; do
			[ -x $HELPER ] && $HELPER $INTERFACE $DNS_SERVER
		done
	fi
}


# Stopping everything

stop() {
# fredx181, remove files created from /etc/slitaz/wifibox_udhcpc
rm -f /tmp/no_fail_message    # created from /etc/slitaz/wifibox_udhcpc script
rm -f /tmp/no_connect_message   # created from /etc/slitaz/wifibox_udhcpc script
	echo 'Stopping all interfaces'
	for iface in $(ifconfig | sed -e '/^[^ ]/!d' -e 's|^\([^ ]*\) .*|\1|' -e '/lo/d'); do
		ifconfig $iface down
	done
	ifconfig $WIFI_INTERFACE down
	sleep 1
	echo 'Killing all daemons'
	killall -9 udhcpc
	killall wpa_supplicant 2>/dev/null

	if iwconfig $WIFI_INTERFACE | fgrep -q 'Tx-Power'; then
		echo 'Shutting down Wi-Fi card'
		iwconfig $WIFI_INTERFACE txpower off
	fi
}


start() {

# fredx181 change start, wait until the symlinks appear in /sys/class/net, otherwise the right interface name cannot be found
rfkill unblock all
check_ifaces () {
while true; do
sleep 1
if [ -n "$(ls /sys/class/net | grep -v "lo")" ]; then
break
fi
done
}
export -f check_ifaces

# if no interface found after 20 sec, give up and continue
timeout 20 /bin/bash -c check_ifaces

# find interface name for wired connection
export INTERFACE=$(iwconfig 2>&1 |egrep "^[a-z]"|grep "no wireless" | grep -v "lo\|ppp*" |cut -f1 -d" ")
	sed -i -e s'/^INTERFACE=.*/INTERFACE="'"$INTERFACE"'"/' /etc/network.conf
# fredx181 change end

	# stopping only unspecified interfaces
	interfaces="$(ifconfig | sed -e '/^[^ ]/!d' -e 's|^\([^ ]*\) .*|\1|' -e '/lo/d')"
	case $WIFI in
		# don't stop Wi-Fi Interface if Wi-Fi selected
		yes) interfaces="$(echo "$interfaces" | sed -e "/^$WIFI_INTERFACE$/d")";;
	esac
	for iface in $interfaces; do
		ifconfig $iface down
	done
if [ -n "$(iwconfig 2>&1 |egrep "^[a-z]"|grep -v "no wireless" |cut -f1 -d" ")" ]; then
	eth; wifi
	dhcp; static_ip
	reconnect_wifi_network
else
	eth
	dhcp; static_ip
fi

	# change default LXPanel panel iface
	if [ -f /etc/lxpanel/default/panels/panel ]; then
		sed -i "s/iface=.*/iface=$INTERFACE/" /etc/lxpanel/default/panels/panel
	fi
}


# Looking for arguments:

case "$1" in
	'')
		boot; start ;;
	start)
		start ;;
	stop)
		stop ;;
	restart)
		stop; sleep 2; start ;;
	*)
		cat <<EOT

$(boldify 'Usage:') /etc/init.d/$(basename $0) [start|stop|restart]

Default configuration file is $(boldify '/etc/network.conf')
You can specify another configuration file in the second argument:
/etc/init.d/$(basename $0) [start|stop|restart] file.conf

EOT
		;;
esac
