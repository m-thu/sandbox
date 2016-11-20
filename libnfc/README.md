libnfc
------

Install libnfc:
```sh
git clone https://github.com/nfc-tools/libnfc.git
cd libnfc
autoreconf -is --force
./configure && make && sudo make install
sudo sh -c 'echo /usr/local/lib >>/etc/ld.so.conf' && sudo ldconfig
```

Install udev rule for ACR122U and blacklist `nfc` and `pn533` modules:
```sh
sudo cp 80-acr122u.rules /etc/udev/rules.d/
sudo cp blacklist-pn533.conf /etc/modprobe.d/
```

### Resources
* [Libnfc - NFC Tools](http://nfc-tools.org/index.php?title=Libnfc)
* [Libnfc API Reference](http://www.libnfc.org/api/)
* [Libnfc on GitHub](https://github.com/nfc-tools/libnfc)
