Cowrie SSH Honeypot (Raspberry Pi)
==================================

`gawk, dig`:
```sh
sudo apt-get install gawk dnsutils
```
`crontab`:
```sh
0 0 * * * /home/pi/cowrie-stats.sh && /home/pi/cowrie-upload
```
