#!/usr/bin/env bash

# Install brnet-nmcli on a Debian-ish system (using /etc/default and
# NetworkManager).  Must be run as root.

tgt="/usr/local/sbin"
if [ -n "$1" ]; then
    tgt=$1
fi
if [ -n "$2" ]; then
    echo "$0 [target-directory]" 1>&2
    exit 1
fi

def="/etc/default/brnet"
if [ -e "${def}" ]; then
    cp "${def}" "${def}.save"
fi
sed -e "s|/usr/local/sbin|${tgt}|" < ./brnet-default > "${def}"
chmod 0644 ${def}

nmdir="/etc/NetworkManager/dispatcher.d"
nmup="${nmdir}/20-brnet"
nmdn="${nmdir}/pre-down.d/20-brnet"
for t in "${nmup}" "${nmdn}"; do
    install -m 0755 -o root -g root nm-action "${t}"
done

install -m 0755 -o root -g root brnet-nmcli "${tgt}/brnet-nmcli"
