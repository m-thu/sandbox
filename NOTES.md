### vim and ctags

Jump to tag under cursor: `CTRL-]`

Jump back: `CTRL-o` or `CTRL-t`

Show tag in split preview window, don't move cursor: `CTRL-w }`

Close preview window: `CTRL-w z`

Show tag in split preview window, move cursor to preview windows: `CTRL-w ]`

Close preview window: `CTRL-w c`

Go to definition of word under cursor in current function: `gd`

Go to definition in current file: `gD`

### Install SystemC

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
