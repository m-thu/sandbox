SDS011 dust sensor (Raspberry Pi)
=================================

`/etc/rc.local`:
```sh
su pi -c '/home/pi/sds011/sds011 /dev/ttyUSB0 &'
```

`crontab`:
```sh
0 * * * * /home/pi/sds011/makegraphs && /home/pi/sds011/upload
```

[SDS011 dust sensor data](http://mthu.freeshell.org/sds011/index.html)

### References
<https://web.archive.org/web/20160705112431/http://inovafitness.com/software/SDS011%20laser%20PM2.5%20sensor%20specification-V1.3.pdf>

<https://github.com/ryszard/sds011/blob/master/doc/Protocol_V1.3.docx>
