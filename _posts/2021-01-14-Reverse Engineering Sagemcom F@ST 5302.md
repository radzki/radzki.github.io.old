---
title: Reverse Engineering Sagemcom F@ST 5302 - WIP
date: 2021-01-14 22:33:31 -0300
categories: [Reverse Engineering, Embedded]
tags: [FAST5302, WIP]
---

***

## Sherlock Holmes Time

#### Locating the UART on the board (positions):
Looking at the PCB, you will see something like this:

> LEDS (FRONT)

> CPU HEAT SINK

> (4 pin UART)
- RX
- TX
- GND
- 3v3

> YELLOW ETHERNET PORTS (BACK)

***

#### CONNECTING

Using an USB/TTL adapter or even an Arduino with RST shorted to GND you can connect to the board's UART.

```
screen -L /dev/ttyUSB0 115200
```

-L is for logging. Quite useful.

#### GET A BASH!

After you get a tty, you will notice that all default commands you would find on busybox or whatever are forbidden, maybe it's redirecting the stdout. Who knows...

Anyway, we can escape from this cage by using a little trick: running bash along with ping, escaping the limited console and... GUESS WHAT?? Gaining root access.
```
ping 8.8.8.8 -c 1 > /dev/null 2>&1; bash
```

#### ALL IN ALL YOU'RE JUST ANOTHER BRICK IN THE (FIRE)WALL...
Enable remote Telnet (better than using screen, right?)
```
iptables -P INPUT ACCEPT; iptables -P FORWARD ACCEPT; iptables -P OUTPUT ACCEPT; iptables -t nat -F; iptables -F; iptables -X
```
#### I... AM... ROOT!
There are 2 ways of obtaining the password on this router:
1. Cracking the password on /etc/passwd with John the Ripper (A little hard)

2. Investigating the HTML Source Code on the router's Web Page (Easy)

Choose whatever floats your boat.

```
superadmin:1234567gvt
```

***

### TTY Output:

```console
CFE version 7.222.1 for BCM96328 (32bit,SP,BE)
Build Date: Wed Apr  3 15:07:05 CST 2013 (cookiechen@SZ01007.DONGGUAN.CN)
Copyright (C) 2005-2012 SAGEMCOM Corporation.

HS Serial flash device: name ID_W25X64, id 0xef17 size 8192KB
Total Flash size: 8192K with 2048 sectors
Chip ID: BCM6328B0, MIPS: 320MHz, DDR: 320MHz, Bus: 160MHz
Main Thread: TP0
Memory Test Passed
Total Memory: 67108864 bytes (64MB)
Boot Address: 0xb8000000

Board IP address                  : 192.168.1.1:ffffff00  
Host IP address                   : 192.168.1.100  
Gateway IP address                :   
Run from flash/host (f/h)         : f  
Default host run file name        : vmlinux  
Default host flash file name      : bcm963xx_fs_kernel  
Boot delay (0-9 seconds)          : 1  
Board Id (0-4)                    : F@ST5302V2  
Primary AFE ID OVERRIDE           : 0x00000001
Bonding AFE ID OVERRIDE           : 0x00000002
Number of MAC Addresses (1-32)    : 11  
Base MAC Address                  : 2c:39:96:f7:ae:14  
PSI Size (1-64) KBytes            : 40  
Enable Backup PSI [0|1]           : 0  
System Log Size (0-256) KBytes    : 64  
Main Thread Number [0|1]          : 0  
Voice Board Configuration (0-0)   : LE89116  

*** Press any key to stop auto run (1 seconds) ***
```

***

### Useful router commands

#### Cleaning WAN config

```
wan delete service eth3.0
```

#### WAN configuration:

```
wan add service eth3 --protocol ipoe --firewall disable --nat enable --igmp enable --dhcpclient enable
```

#### Default Gateway

```
defaultgateway show
```

```
defaultgateway config eth3.0
```

#### Static DNS

```
dns config static 8.8.8.8 8.8.4.4
```

#### This is for the client PC, if you are having trouble getting the right route

```
sudo ip route add 192.168.2.0/24 via 192.168.25.1 dev wlp2s0
```

***

### Bandwidth

This router ISP firmware has a 10Mbps limitation on the wi-fi :(

To remove it (and also set the channel you want to...):

```
wlctl down; wlctl rate -1; wlctl rateset default; wlctl channel 11; wlctl up
```

***

# WIP

We managed to configure it as a router. In my case, I'm using it to receive Internet via WAN (IPoE) and bridge it to the Wi-Fi.

For an useless router, that basically saved it from trash.

The huge problem that still remains to be solved:

We have no access to the firmware. This implies on reconfiguration everytime the router reboots.
How to extract it? JTAG?

***

### Useful links:
- [Reverse engineering F@ST 2704] https://github.com/Mixbo-zz/FaST2704
- [CLI Reference (wan delete service)] ftp://ftp.zyxel.fr/ftp_download/P-660HN-51/firmware/P-660HN-51_1.12(AADW.7)C0_2.pdf
- [CLI Reference (in chinese...)] http://bbs.mydigit.cn/simple/?t1478045.html
- [GitHub CLI] https://github.com/ad7843/hi/blob/master/cli_cmd.c
- [CLI Rererence (Commands like wlctl)] http://ahmedfarazch.blogspot.com/2013/11/ptcltenda-w150d-and-micronet-sp3367nl.html
- [CFE Dump] https://github.com/openwrt-es/cfe-backup/blob/master/cfetool.py
- [Dumping image:] https://forum.archive.openwrt.org/viewtopic.php?id=55648
- [Restricted Linux Shell Escaping Techniques] https://fireshellsecurity.team/restricted-linux-shell-escaping-techniques/
