#!/usr/bin/env bash

# Install brnet-nmcli on a Debian-ish system (using /etc/default, systemd,
# and NetworkManager).  Must be run as root.

tgt="/usr/local/sbin"
if [ -n "$1" ]; then
    tgt=$1
fi
if [ -n "$2" ]; then
    echo "$0 [target-directory]" 1>&2
    exit 1
fi

install -o root -g root -m 0755 brnet-nmcli "${tgt}"

def="/etc/default/brnet"
if [ -e "${def}" ]; then
    cp "${def}" "${def}.save"
fi
svc="/etc/systemd/system/brnet.service"
sed -e "s|/usr/local/sbin|${tgt}|" < ./brnet-default > "${def}"
sed -e "s|/usr/local/sbin|${tgt}|" < ./brnet.service > "${svc}"
chown root:root ${def} ${svc}
chmod 0644 ${def} ${svc}

systemctl enable brnet.service
