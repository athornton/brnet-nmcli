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
    -u user:           bridge user                    [$BRIDGE_USER |     pi]
    -g group:          tap device owning group        [$NETDEV_GRP  | netdev]
    -i interface:      interface to convert to bridge [$IF          |   eth0]
    -b bridge:         bridge interface name          [$BRIDGE      |    br0]
    -n number-of-taps: number of tap interfaces       [$NUM_TAP     |      4]
	-f first-tap:      number of first tap interface  [$FIRST_TAP   |      0]

Express Installation
--------------------

On Debian "Bookworm", you can just run
`sudo ./install.sh [target-directory]` from the directory containing
[this README.md](./README.md).  If you omit `target-directory` then
`/usr/local/sbin` will be used.


Manual installation On Debian "Bookworm" (or similar)
-----------------------------------------------------

Install `brnet-nmcli` as executable by `root` somewhere (I use
`/usr/local/sbin`).  Install [the brnet settings file](./brnet-settings)
as `/etc/default/brnet` and edit it to suit your own environment.

Install [the brnet systemd unit file](./brnet.service) as
`/etc/systemd/system/brnet.service` and enable the service with
`systemctl enable brnet.service`.

Installation On Other Distributions
-----------------------------------

This is only ever going to work on NetworkManager-managed systems.  If
you are not using NetworkManager (good for you!), then you probably want
[brnet Classic](https://github.com/athornton/brnet) instead.

If you are using NetworkManager, but you don't have systemd and/or the
`/etc/default` directory, the salient point is that you want to run
`brnet-nmcli start` after your network is already up with its real
devices, and run `brnet-nmcli stop` just before you bring your network's
real devices down.  Use environment variables or command-line arguments
to control its operation.
