# piCore-headless
Scripts to help set up piCore (wifi ssh access) completely headless

Based on PiCore 11.0beta1a
See: http://www.tinycorelinux.net
And: http://repo.tinycorelinux.net/11.x/armv6/

Goals:
1) make serial console login work
2) get wifi up
3) automate a couple of steps that would otherwise require a keyboard and screen

Works with:
Tested and developed with a Zero W and a 3B+ using piCore 11.0beta1a

Intents:
To be easily adopted to other piCore versions and Raspberry Pi models

Requirements:
Completely headless setup is meant as: never (ever) is it nescessary to connect a screen and keyboard to the Pi to set it up the way you need to. You will need a computer and internet connection to download piCore, write the images to an SD card, and modify/add a couple of files on the SD card after writing the image.

General procedure (some steps optional depending on need for wireless or serial console access or both):
1) Download piCore
2) Get the required .tcz extensions needed for wireless networking
3) Write the downloaded image to an SD card
4) Mount the first partition (the boot partition)
5) Modify config.txt and cmdline[3].txt
6) Add and setup the 'pre' directory to boot partition (this contains the scripts that will run on first boot)
7) Copy the required .tcz extensions to the boot partition
8) Creat a wpa_supplicant.conf file on the boot partition
9) On first boot: partition 2 will be resized, initramfs remastered, tcz's for wireless copied to partition 2, wireless network joining setup.
10) After a reboot the Pi should automatically join the wifi network and be accessible via ssh. Also the serial console is working.

