#! /vendor/bin/sh

# RockPro64 LEDs (rk3399-rockpro64.dts): work-led (white, heartbeat) and
# diy-led (red). Use diy-led as the boot-storage activity LED, like act-led
# on the Tinker Board 2. mmc1 = SD, mmc2 = eMMC (rk3399.dtsi aliases).
cmdline=$(cat /proc/cmdline)
storage=`echo $cmdline|awk '{print match($0,"storagemedia=emmc")}'`;

if [ $storage -gt 0 ]; then
    #emmc
    echo mmc2 > /sys/class/leds/diy-led/trigger
else
    #sdcard
    echo mmc1 > /sys/class/leds/diy-led/trigger
fi
