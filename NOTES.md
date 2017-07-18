### vim and ctags

Jump to tag under cursor: `CTRL-]`

Jump back: `CTRL-o` or `CTRL-t`

Show tag in split preview window, don't move cursor: `CTRL-w }`

Close preview window: `CTRL-w z`

Show tag in split preview window, move cursor to preview windows: `CTRL-w ]`

Close preview window: `CTRL-w c`

Go to definition of word under cursor in current function: `gd`

Go to definition in current file: `gD`

### Installing SystemC

```sh
wget http://accellera.org/images/downloads/standards/systemc/systemc-2.3.1a.tar.gz
tar xvfz systemc-2.3.1a.tar.gz
cd systemc-2.3.1a/
mkdir objdir
cd objdir/
../configure --prefix=/usr/local/systemc-2.3.1
make
make check
sudo make install
```

### Enable serial console on Raspberry Pi 3

```sh
echo enable_uart=1 >>/boot/config.txt
```

### Using Android Studio with IBus version < 1.5.11

[IDEA-78860: Keyboard input sometimes is blocked when IBus is active](https://youtrack.jetbrains.com/issue/IDEA-78860)

```sh
export IBUS_ENABLE_SYNC_MODE=1
```

### Orange Pi One

* [Allwinner A31 and Allwinner H3 SoC baremetal application](https://github.com/skristiansson/ar100-info)
* [Open firmware for Allwinner H3 SoC](https://github.com/megous/h3-firmware)
* <https://github.com/megous/h3-ar100-firmware-decompiler>
* <http://www.orangepi.org/orangepione/>
* [Installing Debian on Allwinner](https://wiki.debian.org/InstallingDebianOn/Allwinner)
* [armbian - Linux for ARM development boards](https://www.armbian.com/download/)

### Installing Coq on Ubuntu 14.04

```sh
wget https://coq.inria.fr/distrib/V8.6/files/coq-8.6.tar.gz
tar xzf coq-8.6.tar.gz && cd cd coq-8.6
sudo apt-get install ocaml ocaml-findlib camlp5 liblablgtk2-ocaml-dev liblablgtksourceview2-ocaml-dev
./configure && make world && sudo make install && sudo make clean-ide

coqtop # Coq toplevel
coqc   # Coq compiler
coqide # Coq IDE
```

### NetBSD on Raspberry Pi 2

* [NetBSD/evbarm on Raspberry Pi](http://wiki.netbsd.org/ports/evbarm/raspberry_pi/)
* [How to get NetBSD](http://www.netbsd.org/releases/)
* [The NetBSD Guide](http://netbsd.org/docs/guide/en/netbsd.html)
* [NetBSD Internals](http://netbsd.org/docs/internals/en/index.html)
* [NetBSD Documentation: Kernel](http://netbsd.org/docs/kernel/index.html)
* [NetBSD Documentation: Kernel Programming FAQ](http://netbsd.org/docs/kernel/programming.html)
* [NetBSD Device Driver Writing Guide](http://netbsd.org/docs/kernel/ddwg.html)
* [NetBSD Documentation: Writing a pseudo device](http://netbsd.org/docs/kernel/pseudo/index.html)

Crosscompiling NetBSD on Linux:
```sh
mkdir netbsd-src && cd netbsd-src
wget http://cdn.netbsd.org/pub/NetBSD/NetBSD-7.1/source/sets/gnusrc.tgz
wget http://cdn.netbsd.org/pub/NetBSD/NetBSD-7.1/source/sets/sharesrc.tgz
wget http://cdn.netbsd.org/pub/NetBSD/NetBSD-7.1/source/sets/src.tgz
wget http://cdn.netbsd.org/pub/NetBSD/NetBSD-7.1/source/sets/syssrc.tgz
wget http://cdn.netbsd.org/pub/NetBSD/NetBSD-7.1/source/sets/xsrc.tgz
for f in *.tgz; do tar xfz $f; done
cd /usr/src && ./build.sh -U -u -m evbarm -a earmv7hf release
sudo sh -c 'zcat obj/releasedir/evbarm/binary/gzimg/armv7.img.gz |dd bs=4M of=/dev/mmcblk0'
```

### Zybo

Zynq internal temperature sensor:
```sh
cat /sys/devices/amba.0/f8007100.ps7-xadc/temp
```

### stdint.h, inttypes.h

* [<stdint.h>](http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/stdint.h.html): `intptr_t, uintptr_t`
* [<inttypes.h>](http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/inttypes.h.html)
