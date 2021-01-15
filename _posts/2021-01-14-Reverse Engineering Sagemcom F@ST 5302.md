---
title: Reverse Engineering Sagemcom F@ST 5302
date: 2021-01-14 22:33:31 -0300
categories: [Reverse Engineering, Embedded]
tags: [FAST5302]
---

UART on the board:

HEATSINK

- RX
- TX
- GND
- 3v3

YELLOW ETHERNET


###########################

- GET A BASH!
	 ping 8.8.8.8 -c 1 > /dev/null 2>&1; bash

- ALL IN ALL YOU'RE JUST ANOTHER BRICK IN THE (FIRE)WALL...
	iptables -P INPUT ACCEPT; iptables -P FORWARD ACCEPT; iptables -P OUTPUT ACCEPT; iptables -t nat -F; iptables -F; iptables -X
	
- I... AM... ROOT!
	superadmin:1234567gvt

###########################

- Para LIMPAR config WAN:

  wan delete service eth3.0

- Para configurar modo WAN (escolha um deles):

  wan add service eth3 --protocol ipoe --firewall disable --nat enable --igmp enable --dhcpclient enable

  #wan add service eth3 --protocol ipoe --firewall disable --nat enable --igmp enable --dhcpclient enable --gatewayifname eth3.0 --dnsifname eth3.0

  #wan add service eth3 --protocol ipoe --firewall disable --nat disable --igmp enable --dhcpclient enable --gatewayifname eth3.0 --dnsifname eth3.0	

  #wan add service eth3 --protocol ipoe --firewall disable --nat disable --igmp enable --dhcpclient disable --ipaddr 192.168.2.50 255.255.255.0 --gatewayifname eth3.0 --dnsifname eth3.0

  defaultgateway show

  defaultgateway config eth3.0
  dns config static 8.8.8.8 8.8.4.4

- Para o computador HOST

  sudo ip route add 192.168.2.0/24 via 192.168.25.1 dev wlp2s0

##########################

Aumentar velocidade:

wlctl down; wlctl rate -1; wlctl rateset default; wlctl channel 11; wlctl up
