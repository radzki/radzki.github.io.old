---
title: Reverse Engineering Philco PH32B51DSGWVB SMART TV
date: 2021-01-15 14:08:01 -0300
categories: [Reverse Engineering, Embedded]
tags: [Philco, PH32B51DSGWVB]
---

### IPTV on Old TV?

The goal here was to install SS-IPTV for my grandpa, so he could watch TV on his own to get a little less bored on this pandemic. This app allows you to watch IPTV (m38, m3u8) on your SmartTV.

First, we get the original firmware from the manufacturer's website:
https://www.philco.com.br/site_o/index.php/indexs/drivers/

Type in your serial number and download it.

***

### Hands on

```console
$ binwalk PH32B51DSGWVB.orig.bin

DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
0             0x0             POSIX tar archive, owner user name: "img"
```

Hmm, simple as that? It appears the file is just a tar archive. I made a little script to extract it:

```extract_bin.sh
#!/bin/bash

mkdir PH32B51DSGWVB; cd PH32B51DSGWVB/; tar -xvf ../$1
```
cd into the directory, then ls:

```console
0.vmlinux.rescue.bin  checksum.exe  customer     font.ttf   mkfs.jffs2     mkyaffs2imageExt  nandwrite  srootfs.img  video_firmware.install.bin
busybox               config.txt    flash_erase  install_a  mkyaffs2image  mm2               package2   uEGBK.mbf
```

These are the files on the archive.

After some investigation, I found out the file we're looking for: **squashfs1.img**

```console
$ cd package2

$ binwalk squashfs1.img

DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
0             0x0             Squashfs filesystem, little endian, version 4.0, compression:gzip, size: 99022797 bytes, 2588 inodes, blocksize: 131072 bytes
```

Now, we need to unsquash the filesystem :
```console
$ unsquashfs squashfs1.img
```
```console
$ cd squashfs-root
$ ls

bin  dev  etc  lib  mnt  proc  sbin  sys  tmp  tmp_orig  usr  var
```

Ta dah! This is a very interesting puzzle.

The files located at **/usr/local/bin/dfbApp/qt/Resource/ui_script/TV036_1_ISDB** are also curious. They are a bunch of **RSS** files using **XML** and **LUA** scripts.

For example, **NetworkPage.rss**

```console
$ cat NetworkPage.rss

<?xml version='1.0' ?>
<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/">

	<bookmark>MainMenu - Media</bookmark>
<onEnter>
	/* notice!!!!! */
	print("Network page onEnter in");
    projectDir = "TV036_1_ISDB";
	itemSize = 0;
	subItemList = "";
    subItemImage = "";
	/*
    subItemList = pushBackStringArray(subItemList, "$[USB]");
    subItemImage = pushBackStringArray(subItemImage, "./Resource/ui_script/"+projectDir+"/Network/Media.png");
    itemSize = itemSize + 1;*/

	if (Misc_IsYoutubeEnable() == "TRUE") {
        subItemList = pushBackStringArray(subItemList, "$[YOUTUBE]");
        subItemImage = pushBackStringArray(subItemImage, "./Resource/ui_script/"+projectDir+"/Network/YOUTUBE.png");
		itemSize = itemSize + 1;
	}

	if (Misc_IsQJYBrowserEnable() == "TRUE"){
        subItemList = pushBackStringArray(subItemList, "$[ALL_APP]");
        subItemImage = pushBackStringArray(subItemImage, "./Resource/ui_script/"+projectDir+"/Network/BROWSER.png");
		itemSize = itemSize + 1;
	}

	if (Misc_IsFlickrEnable() == "TRUE") {
        subItemList = pushBackStringArray(subItemList, "$[FLICKR]");
        subItemImage = pushBackStringArray(subItemImage, "./Resource/ui_script/"+projectDir+"/Network/FLICKR.png");
		itemSize = itemSize + 1;
	}
	if (Misc_IsTwitterEnable() == "TRUE") {
        subItemList = pushBackStringArray(subItemList, "$[TWITTER]");
        subItemImage = pushBackStringArray(subItemImage, "./Resource/ui_script/"+projectDir+"/Network/TWITTER.png");
		itemSize = itemSize + 1;
	}
    /*
	if (Misc_IsDLNAEnable() == "TRUE")
    {
        print("dhs DLNA OK");
        subItemList = pushBackStringArray(subItemList, "$[NSCREEN]");
        subItemImage = pushBackStringArray(subItemImage, "./Resource/ui_script/"+projectDir+"/Network/NSCREEN.png");
		itemSize = itemSize + 1;
	}
	*/
	if (Misc_IsFacebookEnable() == "TRUE") {
        subItemList = pushBackStringArray(subItemList, "$[FACEBOOK]");
        subItemImage = pushBackStringArray(subItemImage, "./Resource/ui_script/"+projectDir+"/Network/FACEBOOK.png");
		itemSize = itemSize + 1;
	}
	if (Misc_IsPicasaEnable() == "TRUE") {
        subItemList = pushBackStringArray(subItemList, "$[PICASA]");
        subItemImage = pushBackStringArray(subItemImage, "./Resource/ui_script/"+projectDir+"/Network/PICASA.png");
		itemSize = itemSize + 1;
	}

	subItemList = pushBackStringArray(subItemList, "$[MEDIA]");
    subItemImage = pushBackStringArray(subItemImage, "./Resource/ui_script/"+projectDir+"/Network/USB.png");
    itemSize = itemSize + 1;

	/*
	if (Misc_IsQJYBrowserEnable() == "TRUE"){
        subItemList = pushBackStringArray(subItemList, "$[Philco]");
        subItemImage = pushBackStringArray(subItemImage, "./Resource/ui_script/"+projectDir+"/Network/philco.png");
		itemSize = itemSize + 1;
	}
    	*/
	/*
	if (Misc_IsUOLEnable() == "TRUE") {
        subItemList = pushBackStringArray(subItemList, "$[UOL]");
        subItemImage = pushBackStringArray(subItemImage, "./Resource/ui_script/"+projectDir+"/Network/UOL.png");
		itemSize = itemSize + 1;
	}
	if (Misc_IsTerraTVEnable() == "TRUE") {
        subItemList = pushBackStringArray(subItemList, "$[TERRATV]");
        subItemImage = pushBackStringArray(subItemImage, "./Resource/ui_script/"+projectDir+"/Network/TERRATV.png");
		itemSize = itemSize + 1;
	}
	if (Misc_IsIGEnable() == "TRUE") {
        subItemList = pushBackStringArray(subItemList, "$[IGTV]");
        subItemImage = pushBackStringArray(subItemImage, "./Resource/ui_script/"+projectDir+"/Network/IGTV.png");
		itemSize = itemSize + 1;
	}
	if (Misc_IsNetflixEnable() == "TRUE")
    {
        subItemList = pushBackStringArray(subItemList, "$[NETFLIX]");
        subItemImage = pushBackStringArray(subItemImage, "./Resource/ui_script/"+projectDir+"/Network/NETFLIX.png");
		itemSize = itemSize + 1;
	}
    */
	focusIndex = 0;

	redrawDisplay();
</onEnter>

<onExit>

</onExit>

<onRefresh>
</onRefresh>

<mediaDisplay
	name=onePartView

    viewAreaXPC=0
    viewAreaYPC=0
    viewAreaWidthPC=100
    viewAreaHeightPC=100

	sideColorRight=-1:-1:-1
	sideColorLeft=-1:-1:-1
	sideColorTop=-1:-1:-1
	sideColorBottom=-1:-1:-1
	backgroundColor=-1:-1:-1
	focusBorderColor=-1:-1:-1
	unFocusBorderColor=-1:-1:-1
	itemBackgroundColor=0:0:0

	itemColumnNum=1
	enableBgSurface="yes"

>

	<backgroundDisplay name=fileBrowser reduceBufferPC="100">
		<image offsetXPC=0 offsetYPC=0 widthPC=100 heightPC=100 isForceDestAlpha=yes useCache=yes>
		    <script>
			    image = "./Resource/ui_script/"+projectDir+"/Network/IMG_BACKGROUND.png";
            </script>
		</image>
	</backgroundDisplay>

	<!--------------------  bar  -------------------------------------->
	<image offsetXPC=27.66 offsetYPC=26.39 widthPC=12.97 heightPC=22.78 isForceDestAlpha=yes useCache=yes redraw=no>
	    <script>
	        image = getStringArrayAt(subItemImage, 0);
        </script>
	</image>

	[...]

	<!---
	<image offsetXPC=63.44 offsetYPC=49.26 widthPC=14.59 heightPC=26.11 isForceDestAlpha=yes useCache=yes redraw=no>
	    <script>
		    image = "";
			if(focusIndex == 7)
		 	   image = "./Resource/ui_script/"+projectDir+"/Network/ITEM_FOCUS.png";
			image;
        </script>
	</image>
	---->

	<onUserInput>
		ret = "false";
		userInput = currentUserInput();
		print("===adjust userInput==="+userInput);
		preFocusIndex = focusIndex;


    		if (userInput == "menu")
		{
			ret = "true";
		}
		else if (userInput == "left" || userInput == "right" )
		{
			if (userInput == "right" )
			{
				prefocusIndex = focusIndex;
				focusIndex = Add(focusIndex , 1);
				if(focusIndex &gt;=itemSize)
					focusIndex = 0;
			}
			else
			{
				prefocusIndex = focusIndex;
				if(focusIndex &lt;=0)
					focusIndex = Minus(itemSize , 1);
				else
					focusIndex = Minus(focusIndex , 1);
			}
			redrawDisplay();
			ret = "true";
		}
		else if (userInput == "up" || userInput == "down")
		{
           		if (focusIndex &gt;= 0 &amp;&amp; focusIndex &lt; 3)
			{
				prefocusIndex = focusIndex;
				focusIndex = Add(focusIndex , 3);
			}
			else
			{
				prefocusIndex = focusIndex;
				focusIndex = Minus(focusIndex,3);
			}
			redrawDisplay();
			ret = "true";
		}
		else if (userInput == "enter") {
           /* if (Misc_IsQtTestBrowser_Initialized() == "FALSE") {
                activateOsdWin("BrowserNotReady");
            } else*/ {
            select = getStringArrayAt(subItemList, focusIndex);
            print("dhs select:"+select);
            deactivateCurOsdWin();
            if(select == "$[YOUTUBE]")
			{
				Misc_SwitchToYoutube();
			}
			else if(select == "$[FLICKR]")
			{
				Misc_SwitchToNetMoive();
				/*Misc_SwitchToFlickr();*/
			}
			else if(select == "$[TWITTER]")
			{
				Misc_SwitchToTwitter();
			}
			else if(select == "$[NSCREEN]")
			{
				Misc_SetDLNAEnable();
			}
			else if(select == "$[FACEBOOK]")
			{
				Misc_SwitchToFacebook();
			}		
			else if(select == "$[PICASA]")
			{
				Misc_SwitchToPicasa();				
			}
			else if(select == "$[UOL]")
			{
				Misc_SwitchToUOL();
			}
			else if(select == "$[TERRATV]")
			{
				Misc_SwitchToTerraTV();
			}
			else if(select == "$[IGTV]")
			{
				Misc_SwitchToIG();
			}
			else if(select == "$[NETFLIX]")
			{
				Misc_SwitchToNetflix();
			}
			else if(select == "$[ALL_APP]")
			{
				Misc_SwitchToQJYBrowser();
			}
			else if(select == "$[MEDIA]")
			{
		        setEnv("MediaTitleIndex", 0);
                 activateOsdWin("mediamenu");                  
            }
			else if(select == "$[Philco]")
			{
				Misc_SwitchToPhilco();
            }
			/*redrawDisplay();*/
            }
			ret = "true";
		}
		else if (userInput == "return" || userInput == "pagedown") {

			Rss_DeactivateAllOsdWin();
			Source_SetDeferredSource(0);
			/*System_SwitchToRoot();*/
			ret = "true";
		}

		[...]

		print("===ret==="+ret);
		ret;
	</onUserInput>
</mediaDisplay>

<channel>
	<title>$[CHANNEL]</title>
	<link>rss_file://./Resource/ui_script/TV036_1_ISDB/mainMenu_channel.rss</link>		
</channel>

</rss>
```

It describes one of the system's windows. My plan is to replace the function "Misc_SwitchToPicasa()" with something like "Misc_SwitchToSSIPTV()".

But who the hell reads this file in order to show it on the screen?


...


After some time spent looking through the files, I found out the main one. The one that's executed right after booting. The one that does ALL of the TV stuff: **DvdPlayer**

Now, THAT'S an interesting binary (and naming for it, hehe...).


Looking at its strings reveals some nice info:
```console
$ strings DvdPlayer | grep -i PICASA

-------------------- Picasa Slideshow ------------------
Picasa_StartSlideshow
Picasa_EndSliderShow
Picasa_GetSignature
Picasa_SetToken
Picasa_GetToken
Picasa_SetUserID
Picasa_GetUserID
/tmp/www/Picasa
http://localhost/Picasa/picasa_login.html
Misc_IsPicasaEnable
Misc_SwitchToPicasa
```

Running binwalk:

```console
$ binwalk DvdPlayer

DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
0             0x0             ELF, 32-bit LSB MIPS64 executable, MIPS, version 1 (SYSV)
257963        0x3EFAB         mcrypt 2.2 encrypted data, algorithm: blowfish-448, mode: CBC, keymode: 8bit
1360029       0x14C09D        Neighborly text, "NeighborSecurityE6on_offignalStandbyEb"
1413746       0x159272        Neighborly text, "NeighborSecurityEiPPcPv_ZN14NetAddressListC2EPKc"
1515816       0x172128        Neighborly text, "NeighborSecurityEvableC1ER16UsageEnvironment"
1560303       0x17CEEF        Neighborly text, "NeighborSecurityE6on_offndleEventsEP10_tagNAVBUF"
1671563       0x19818B        Copyright string: "copyright_notice"
12537017      0xBF4CB9        Unix path: /sys/realtek_boards/rtice_enable
12542764      0xBF632C        Unix path: /usr/local/etc/dvdplayer/dtv_channel.txt
12543323      0xBF655B        Unix path: /usr/local/etc/qjydata/addressBox
12543678      0xBF66BE        Unix path: /usr/local/etc/dvdplayer/*
12544576      0xBF6A40        Unix path: /sys/realtek_boards/bootloader_version
12566080      0xBFBE40        Neighborly text, "Neighbors/)- KELLYKELLY - Exceed file container"
12566196      0xBFBEB4        Unix path: /var/lock/hotplug/mount_tmp
12574006      0xBFDD36        Unix path: /usr/local/etc/dvdplayer/VenusSetup.dat*
12575386      0xBFE29A        Unix path: /sys/realtek_boards/bootloader_version failed
12576836      0xBFE844        Unix path: /etc/dvdplayer/script
12577276      0xBFE9FC        Unix path: /dev/misc/rtc
12587614      0xC0125E        Neighborly text, "neighbor name : %s ,IP : %s"
12587771      0xC012FB        Neighborly text, "Neighbors%s"
12590494      0xC01D9E        Unix path: /sys/realtek_boards/bootloader_version failed
12592828      0xC026BC        Unix path: /sys/realtek_boards/RSA_KEY_MODULUS
12596960      0xC036E0        Unix path: /dev/mcp/cipher
12597932      0xC03AAC        Unix path: /dev/mcp/dgst
12598924      0xC03E8C        Unix path: /dev/mcp/core
12602066      0xC04AD2        Unix path: /sys/module/rtice2/parameters/%s
12612244      0xC07294        Unix path: /usr/local/etc/hdd/dvdvr
12624880      0xC0A3F0        Unix path: /sys/devices/platform/sata_rtk/re_scan
12625024      0xC0A480        Unix path: /sys/bus/usb/devices/%s/bPortReset;
12625074      0xC0A4B2        Unix path: /sys/bus/usb/devices/usb%s/bPortNumber;
12625128      0xC0A4E8        Unix path: /sys/bus/usb/devices/usb%s/bPortReset;
12626152      0xC0A8E8        Unix path: /sys/bus/scsi/drivers/sd
12626548      0xC0AA74        Unix path: /usr/local/sbin/mkntfs -v -f %sp1
12627380      0xC0ADB4        Unix path: /usr/local/sbin/mkntfs -v -f %s%d
12627828      0xC0AF74        Unix path: /dev/input/event%s
12634476      0xC0C96C        Unix path: /usr/local/etc/dvdplayer/directfbrc
12638046      0xC0D75E        Unix path: /sys/block/sda/scsi_timeout
12653080      0xC11218        Unix path: /dev/input/mice
12655992      0xC11D78        Unix path: /usr/local/etc/
12656156      0xC11E1C        Unix path: /usr/local/etc/directfbrc.
12675992      0xC16B98        Unix path: /dev/misc/psaux
12677420      0xC1712C        GIF image data 17448
12694852      0xC1B544        Unix path: /dev/cec/0
12703028      0xC1D534        Copyright string: "Copyright (C) 1998, Thomas G. Lane"
12709480      0xC1EE68        Unix path: /usr/local/etc/hdd/dvdvr
12722184      0xC22008        HTML document header
12722723      0xC22223        HTML document footer
12726964      0xC232B4        XML document, version: "1.0"
12755386      0xC2A1BA        Copyright string: "Copyright:buffer;"
12757136      0xC2A890        Copyright string: "copyright  : %s"
12773980      0xC2EA5C        Unix path: /sys/realtek_boards/AES_IMG_KEY
12825000      0xC3B1A8        Unix path: /usr/local/etc/dvdplayer/dtv_channel2.txt
12847631      0xC40A0F        Copyright string: "Copyright 1995-2005 Mark Adler "
12847920      0xC40B30        CRC32 polynomial table, little endian
12852016      0xC41B30        CRC32 polynomial table, big endian
12856282      0xC42BDA        Copyright string: "Copyright (c) 1998-2007 Glenn Randers-Pehrson"
12856331      0xC42C0B        Copyright string: "Copyright (c) 1996-1997 Andreas Dilger"
12856373      0xC42C35        Copyright string: "Copyright (c) 1995-1996 Guy Eric Schalnat, Group 42, Inc."
12865835      0xC4512B        Unix path: /usr/local/etc/dvdplayer/*
12869804      0xC460AC        Unix path: /usr/local/etc/dvdplayer/dtvChannel.bin
12880352      0xC489E0        Unix path: /usr/local/etc/dvdplayer/FDT_ADV/
12885436      0xC49DBC        Unix path: /usr/local/etc/dvdplayer/vipTable/yppGainOffset
12885812      0xC49F34        Unix path: /usr/local/etc/dvdplayer/vipTable/
12986540      0xC628AC        Unix path: /usr/local/etc/hdd/dvdvr/dvb/
12986892      0xC62A0C        Unix path: /usr/local/etc/hdd/root/
12987091      0xC62AD3        Unix path: /usr/local/etc/hdd/dvdvr/dvb/
12996328      0xC64EE8        Unix path: /sys/realtek_boards/system_parameters
13032904      0xC6DDC8        Base64 standard index table
13036276      0xC6EAF4        Unix path: /usr/local/etc/dvdplayer/
13039596      0xC6F7EC        Unix path: /sys/realtek_boards/dvrfs_buffer
13052924      0xC72BFC        Unix path: /usr/local/etc/dvdplayer/savedrss/
13060616      0xC74A08        Ubiquiti firmware header, third party, ~CRC32: 0x2D434243, version: "SSLDIR: "/usr/local/ssl""
13112028      0xC812DC        SHA256 hash constants, little endian
13115440      0xC82030        Base64 standard index table
13119056      0xC82E50        Unix path: /usr/local/ssl/private
13182248      0xC92528        Unix path: /usr/local/ssl/lib/engines
13217888      0xC9B060        Unix path: /usr/local/etc/install.img
13221220      0xC9BD64        Unix path: /usr/local/etc/dvdplayer/schedule_record.db
13263756      0xCA638C        Unix path: /usr/bin/ntlm_auth
13266064      0xCA6C90        Base64 standard index table
13275388      0xCA90FC        Unix path: /dev/i2c/0
13277440      0xCA9900        Unix path: /usr/local/etc/dvdplayer/intentValue
13416164      0xCCB6E4        Unix path: /var/lock/dhcp.eth0
13418212      0xCCBEE4        Unix path: /var/run/wpa.conf
13418359      0xCCBF77        Unix path: /var/lock/wpa_supplicant.pid -g/var/run/wpa_supplicant-global -i%s -c /var/run/wpa.conf -b%s -B
13419196      0xCCC2BC        Unix path: /etc/ppp/pap-secrets
13419236      0xCCC2E4        Unix path: /etc/ppp/chap-secrets
13420212      0xCCC6B4        Unix path: /usr/local/etc/ppp/resolv.conf
13420304      0xCCC710        Unix path: /var/lock/dhcp.ok
13420628      0xCCC854        Unix path: /var/lock/wpa_supplicant.pid
13420716      0xCCC8AC        Unix path: /sys/class/net/ppp0/carrier
13421079      0xCCCA17        Unix path: /var/run/hostapd
13421804      0xCCCCEC        Unix path: /var/run/hostapd.conf
13423644      0xCCD41C        Unix path: /usr/local/etc/dvdplayer/NetworkBrowser.ini
13427392      0xCCE2C0        XML document, version: "1.0"
13432344      0xCCF618        Unix path: /usr/local/etc/dvdplayer/BTSAMBA_state
13434380      0xCCFE0C        Unix path: /sys/realtek_boards/bootup_version
13435741      0xCD035D        Unix path: /sys/realtek_boards/misc_operations
13436460      0xCD062C        Unix path: /var/lock/.DvdPlayer
13442972      0xCD1F9C        Unix path: /usr/local/etc/dvdplayer/dvd_discs.db
13451026      0xCD3F12        Unix path: /usr/local/etc/dvdplayer/certs
13456556      0xCD54AC        Unix path: /sys/module/mt7601Usta
13458989      0xCD5E2D        Unix path: /sys/realtek_boards/reclaim_dvr
13459852      0xCD618C        Unix path: /sys/realtek_boards/pcb_enum
13474484      0xCD9AB4        Unix path: /usr/local/etc/dvdplayer/VenusSetup.dat.bak
13474576      0xCD9B10        Unix path: /usr/local/etc/dvdplayer/VenusSetup.dat
13498584      0xCDF8D8        Base64 standard index table
13517952      0xCE4480        Base64 standard index table
13529552      0xCE71D0        Base64 standard index table
13531808      0xCE7AA0        SHA256 hash constants, little endian
13539776      0xCE99C0        XML document, version: "1.0"
13576324      0xCF2884        Unix path: /sys/drivers/realtek/edid_%d
14636758      0xDF56D6        Neighborly text, "NeighborSecurityrk_WlanScanFinish"
14756773      0xE12BA5        MPEG transport stream data
```

Using GHidra (https://ghidra-sre.org/) to decompile the binary and look for the Picasa Functions was very successful. I found out that it uses qjyBrowser, located at **/usr/local/bin/dfbApp/qjyBroser**.

Let's replace the Picasa Login URL located at the Misc_SwitchToPicasa() function, on the .data segment of DvdPlayer with SS-IPTV URL (https://app.ss-iptv.com/).

After that, we save it and repack the image.

I made another script to resquash the image. Run it inside **package2** directory:

```resquash.sh
#!/bin/bash

rm squashfs1.img;
sudo chown -R root:root squashfs-root/;
mksquashfs squashfs-root/ squashfs1.img;
sudo rm -rf squashfs-root;
```

Repacking:

```repack_bin.sh
#!/bin/bash

cd PH32B51DSGWVB;
pax -wf ../PH32B51DSGWVB.bin *;
```

Now, let's copy the binary to a flash drive and plug it on the TV, then flash it.

IT WORKS! Well, kind of. The aforementioned qjyBrowser is not compatible with SS-IPTV.

**DAMN IT!!**

How the hell does YouTube work on this piece of old hardware??

Let's go back to GHidra.

After some further investigation, it turned out that YouTube runs on ANOTHER BROWSER!

```
SwitchToYoutube()

execQtTestBrowser.sh -useragent %s -no-loading-status -remote-inspector-port 9222 -service-type youtube http://www.youtube.com/tv
```

Well, it appears that Flickr service also uses QtBrowser. So we replace Flick URL with SS-IPTV URL. I didn't replace YouTube's because it actually works and my grandpa uses it, hehe.

```
SwitchToFlickr()

execQtTestBrowser.sh -useragent %s -no-loading-status -remote-inspector-port 9222 -service-type youtube http://app.ss-iptv.com/
```

Time to repack everything back and test it out.

Of course, according to Murphy's law, it didn't work.

SS-IPTV javascript bundle requires that the MAC Address of the host device, and this TV does not have this functionality. Also, it needs "window.history", which the browser doesn't support either.
To bypass this inconvenient, let's edit the .js file and save it locally.

Oh yes! I forgot to mention. The TV runs some kind of light httpd server with cgi and all of that. We'll use it to host SS-IPTV modified javascript bundle.

Bypassing _deviceInfoInterface error:
```javascript
this._deviceInfoInterface.history = function(){return []};
```

Bypassing MAC Address error by setting it statically:

```javascript
prepareMAC: function (a) {
            if (null == a || "" == a) return "00:00:00:00:00:00";
            var b;
            b = null == a ? (a = "") : (a = x.trim(null == a ? "null" : "" + a));
            return ":" != q.substr(b, 2, 1) && 12 <= a.length
                ? (q.substr(a, 0, 2) + ":" + q.substr(a, 2, 2) + ":" + q.substr(a, 4, 2) + ":" + q.substr(a, 6, 2) + ":" + q.substr(a, 8, 2) + ":" + q.substr(a, 10, 2)).toLowerCase()
                : a.toLowerCase();
        },
get_netWiredMAC: function () {
    var a;
    a = null == this._deviceInfoInterface ? "00:00:00:00:00:00" : this._deviceInfoInterface.get(18);
    "" != f.getArgumentValue("wiredMAC") && (a = f.getArgumentValue("wiredMAC"));
    return this.prepareMAC(a);
},
get_netWirelessMAC: function () {
    return this.prepareMAC(null == this._deviceInfoInterface ? "00:00:00:00:00:00" : this._deviceInfoInterface.get(19));
}

```

The httpd root directory now looks like this:
```console
$ ls tmp_orig/www/

index.html  tv.js
```

Again, let's repack and flash it.

<a href="https://ibb.co/rHkWWFT"><img src="https://i.ibb.co/m4Jxxb1/efece87a-17ba-40e6-89e1-ac80c5fc942f.jpg" alt="efece87a-17ba-40e6-89e1-ac80c5fc942f" border="0"></a>

**It works!**

I mean, the UI is quite slow, but it streams seamlessly.

This TV was really challenging and fun to work with. I intend to go back on exploring it later.
