Temperature control (Raspberry Pi 2)
====================================

### raspi-config
* 3 Boot Options -> Wait for network at boot -> No
* 5 Interfacing Options -> P5 I2C -> Yes
* 5 Interfacing Options -> P7 1-Wire -> Yes

### DS1307 module
Remove `R2` and `R3` pullups (3K3)

Wiring:
```
5 V      ------ VCC (DS1307)
I2C1 SCL <----> SCL (DS1307)
I2C1 SDA <----> SDA (DS1307)
GND      ------ GND (DS1307)
```

Test module with `sudo i2cdetect -y 1`:
```
     0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
00:          -- -- -- -- -- -- -- -- -- -- -- -- -- 
10: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
20: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
30: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
40: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
50: 50 -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
60: -- -- -- -- -- -- -- -- 68 -- -- -- -- -- -- -- 
70: -- -- -- -- -- -- -- --                        
```

`/etc/rc.local`:
```sh
/bin/echo ds1307 0x68 >/sys/class/i2c-adapter/i2c-1/new_device
hwclock -s
```

```sh
sudo sh -c 'echo rtc-ds1307 >>/etc/modules'
```

### GPIOs
`/etc/rc.local`:
```sh
# GPIO 27: Heater 1 (output)
/bin/echo 27 >/sys/class/gpio/export
/bin/echo out >/sys/class/gpio/gpio27/direction

# GPIO 22: Heater 2 (output)
/bin/echo 22 >/sys/class/gpio/export
/bin/echo out >/sys/class/gpio/gpio22/direction

# GPIO 16: Status LED (output)
/bin/echo 16 >/sys/class/gpio/export
/bin/echo out >/sys/class/gpio/gpio16/direction

# GPIO 26: Shutdown switch (input, active low)
/bin/echo 26 >/sys/class/gpio/export
/bin/echo in >/sys/class/gpio/gpio26/direction
```

`/etc/rc.local`:
```sh
nohup /home/pi/shutdown.sh &
date >>/root/startup.log
```

### DS18B20
Wiring:
```
3.3 V  --o---- VDD (DS18B20)
         |
        ---
        | | 4K7
        | | Pullup
        | |
        ---
         |
GPIO 4 <-o---> DQ  (DS18B20)
GND    ------- GND (DS18B20)
```

Test sensors:
```sh
pi@raspberrypi:~ $ ls -l /sys/bus/w1/devices/
total 0
lrwxrwxrwx 1 root root 0 May 12 20:52 28-0416927dcdff -> ../../../devices/w1_bus_master1/28-0416927dcdff
lrwxrwxrwx 1 root root 0 May 12 20:52 28-051691e2c3ff -> ../../../devices/w1_bus_master1/28-051691e2c3ff
lrwxrwxrwx 1 root root 0 May 12 20:52 28-051691e533ff -> ../../../devices/w1_bus_master1/28-051691e533ff
lrwxrwxrwx 1 root root 0 May 12 20:52 w1_bus_master1 -> ../../../devices/w1_bus_master1
pi@raspberrypi:~ $ cat /sys/bus/w1/devices/28-0416927dcdff/
driver/    id         name       power/     subsystem/ uevent     w1_slave
pi@raspberrypi:~ $ cat /sys/bus/w1/devices/28-0416927dcdff/w1_slave
6e 01 4b 46 7f ff 0c 10 ad : crc=ad YES
6e 01 4b 46 7f ff 0c 10 ad t=22875
pi@raspberrypi:~ $ cat /sys/bus/w1/devices/28-051691e2c3ff/w1_slave
6e 01 4b 46 7f ff 0c 10 ad : crc=ad YES
6e 01 4b 46 7f ff 0c 10 ad t=22875
pi@raspberrypi:~ $ cat /sys/bus/w1/devices/28-051691e533ff/w1_slave
69 01 4b 46 7f ff 0c 10 7d : crc=7d YES
69 01 4b 46 7f ff 0c 10 7d t=22562
```

### References
[DS1307 datasheet](https://datasheets.maximintegrated.com/en/ds/DS1307.pdf)
[DS18B20 datasheet](https://datasheets.maximintegrated.com/en/ds/DS18B20.pdf)
