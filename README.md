brnet-nmcli
===========

This is the third major iteration of `brnet`, a tool to easily allow
activation of several non-root-owned bridge interfaces.

The first and second versions used `brctl` to provide this
functionality.  As of Debian Bookworm, NetworkManager appears to no
longer be optional, so this version relies on `nmcli`.

The original motivation was to provide for many emulated computers
running on a single Raspberry Pi, each with access to its own dedicated
tap network interface so that it could run as a non-root user and still
bring up an IP stack allowing remote access.

Operation
---------

`brnet-nmcli` has two verbs: `start` and `stop`.  It also has the
following options:

    -h:                display help
    -u user:           bridge user [$BRIDGE_USER | pi]
    -g group:          tap device owning group [$NETDEV_GRP | netdev]
    -i interface:      interface to convert to bridge [$IF | eth0]
    -b bridge:         bridge interface name [$BRIDGE | br0]
    -n number-of-taps: maximum number of tap interfaces [$NUM_TAP | 4]

Installation
------------

Install `brnet-nmcli` as executable by `root` somewhere (I use
`/usr/local/sbin`).  Install [the brnet settings file](./brnet-settings)
as `/etc/default/brnet` and edit it to suit your own environment.

Then add `20-brnet` to `/etc/NetworkDispatcher/dispatcher.d` and to
`/etc/NetworkDispatcher/dispatcher.d/pre-down.d`.  The contents should
be:

	#!/usr/bin/env bash

	interface=$1
	event=$2

	if [ -e /etc/default/brnet ] ; then
		. /etc/default/brnet
	fi
	export BRIDGE_USER NETDEV_GRP IF BRIDGE NUM_TAP FIRST_TAP

	if [ -z "${BRNET}" ]; then
		BRNET="/usr/local/sbin/brnet-nmcli"
	fi

	if [[ $interface == ${IF} ]] && [[ $event == "@@STATE@@" ]]; then
		${BRNET} @@VERB@@
	fi

Where `@@STATE@@` should be replaced by `up` for the first file and
`down` for the second, and `@@VERB@@` should be replaced by `start` for
the first file and `stop` for the second.  These files should be owned
by `root` and be executable.

Express Installation
--------------------

Or, more simply, run `sudo ./install.sh [target-directory]` from this
directory.  If you omit `target-directory` `/usr/local/sbin` will be
used.
