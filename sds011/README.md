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

Local webserver config (`/etc/nginx/nginx.conf`):
```nginx
user www-data;
worker_processes auto;
pid /run/nginx.pid;

events {
        worker_connections 768;
        # multi_accept on;
}

http {
        access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log;

        server {
                location / {
                        root /home/pi/sds011/html;
                        autoindex on;
                }
        }
}
```

### References
<https://web.archive.org/web/20160705112431/http://inovafitness.com/software/SDS011%20laser%20PM2.5%20sensor%20specification-V1.3.pdf>

<https://github.com/ryszard/sds011/blob/master/doc/Protocol_V1.3.docx>
