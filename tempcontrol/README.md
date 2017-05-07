Temp. control
=============

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

# GPIO 26: Shutdown switch (input)
/bin/echo 26 >/sys/class/gpio/export
/bin/echo in >/sys/class/gpio/gpio26/direction
```

### References
[DS1307 datasheet](https://datasheets.maximintegrated.com/en/ds/DS1307.pdf)
