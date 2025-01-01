brnet-nmcli
===========

This is the third major iteration of `brnet`, a tool to easily allow
activation of several non-root-owned bridge interfaces.

The first and second versions used `brctl` to provide this
functionality.  As of Debian Bookworm, NetworkManager appears to no
longer be optional, so this version relies on `nmcli`.

Motivation
----------

I run a lot of historical systems, mostly with
[simh](https://github.com/open-simh/simh), but some with other
emulators.  Simh in particular has no need to run as root in normal
operation, so it would be nice to allow it, when running an OS that
supports a TCP/IP stack, to be able to use the network, and, crucially,
to allow devices from the outside to connect to its TCP/IP stack.

Modern simh allows you to do fairly complicated NAT setup to facilitate
this, but my preference is simply to expose the guest stack as another
IP address on my network.

With this tool it is possible to define an arbitrary number of tap
devices for assignation to the emulated hosts, owned by (and with group
membership also appropriately set) the user that is going to be running
the emulator, and to easily integrate that into system startup and
shutdown.

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

Usage By Emulators
------------------

In the general case, all you need to do is decide which tap device
should be used by which emulator, and configure the emulator
appropriately.

For instance, here's the configuration for [Jonny Bilquist's distribution
of RSX-11M+](http://mim.stupi.net/pidp.htm):

	set cpu 11/70
	set cpu 4096
	set cpu idle
	sho cpu

	set rq0 rauser=1024
	att rq0 pidp.dsk
	sho rq0

	set rq1 autosize
	attach rq1 PiDP11_DU1.dsk

	set tq0 write
	att -f tq0 e11 pidp.tap
	sho tq0

	set clk 50
	set dz lines=8
	att dz 10001,speed=*32
	sho dz

	set xu ena
	set xu type=delua
	set xu mac=aa:00:04:00:2d:2c
	; DECNET Phase IV 11.45
	attach xu tap:tap5
	set xu throttle
	sho xu

	boot rq0

Only the `xu` lines are relevant to TCP/IP networking.  The only part
that is directly relevant here is `attach xu tap:tap5`.  On this host
system I am coupling this particular simh instance to `tap5` created
with the settings:

	# brnet-nmcli settings

	# brnet-nmcli executable
	BRNET="/usr/local/sbin/brnet-nmcli"

	# Default settings
	# BRIDGE_USER="pi"
	# NETDEV_GRP="netdev"
	# IF="eth0"
	# BRIDGE="br0"
	# NUM_TAP=4
	# FIRST_TAP=0

	BRIDGE_USER="adam"
	IF="end0"
	NUM_TAP=12

The differences from the default config are:
* The emulator user is `adam` rather than `pi`.
* The primary ethernet interface is named `end0` rather than `eth0`.
* I am using 12 tap interfaces rather than 4.
