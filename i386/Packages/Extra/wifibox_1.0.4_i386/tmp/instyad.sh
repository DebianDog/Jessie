#!/bin/bash

while fuser /var/lib/dpkg/lock >/dev/null 2>&1; do
   sleep 1
done

VERSION=`yad --version | awk '{ print $1 }'`
verlte() {
    [  "$1" = "`echo -e "$1\n$2" | sort -V | head -n1`" ]
}

verlt() {
    [ "$1" = "$2" ] && return 1 || verlte $1 $2
}

if verlt $VERSION 0.26.0; then
check_network() {
while true; do
sleep 1
wget -q --spider http://google.com

if [ $? -eq 0 ]; then
    echo "Online"
break
fi
done
}
export -f check_network
timeout 30 /bin/bash -c check_network 
	if [ $? -eq 0 ]; then
#wget -P /var/cache/apt/archives/ http://www.smokey01.com/saintless/DebianDog-Jessie/Packages/Included/yad_0.28.1_i386.deb
yad --center --text=" The installed yad version is too old \n Please click OK to upgrade yad."
run_xterm() {
(find /var/lib/apt/lists -type f | grep '_Release') || (/usr/bin/apt-get update)
apt-get install -y --force-yes yad
read -s -n 1 -p "Press any key to close . . ."
}
export -f run_xterm

xterm -T "Installing yad" -si -sb -fg black -bg white -geometry 65x14 -e /bin/bash -c run_xterm
else
 yad --center --text=" Attempted to upgrade yad, but there is no network connection \n The installed yad version is too old \n Please upgrade yad to higher version than 0.25."
	fi
fi
