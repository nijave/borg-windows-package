#!/usr/bin/env bash

which curl
which tar
pipenv run python -u get_cygwin_links.py | tee urls.txt

# tee urls.txt <<EOF
# http://mirrors.kernel.org/sourceware/cygwin/noarch/release/tzdata/tzdata-2019c-1.tar.xz
# http://mirrors.kernel.org/sourceware/cygwin/x86_64/release/libiconv/libiconv2/libiconv2-1.14-3.tar.xz
# http://mirrors.kernel.org/sourceware/cygwin/x86_64/release/gcc/libgcc1/libgcc1-7.4.0-1.tar.xz
# http://mirrors.kernel.org/sourceware/cygwin/x86_64/release/ncurses/terminfo/terminfo-6.1-1.20190727.tar.xz
# http://mirrors.kernel.org/sourceware/cygwin/x86_64/release/ncurses/terminfo-extra/terminfo-extra-6.1-1.20190727.tar.xz
# http://mirrors.kernel.org/sourceware/cygwin/x86_64/release/readline/libreadline7/libreadline7-7.0.3-3.tar.xz
# http://mirrors.kernel.org/sourceware/cygwin/x86_64/release/gettext/libintl8/libintl8-0.19.8.1-2.tar.xz
# http://mirrors.kernel.org/sourceware/cygwin/x86_64/release/tzcode/tzcode-2019c-1.tar.xz
# http://mirrors.kernel.org/sourceware/cygwin/x86_64/release/attr/libattr1/libattr1-2.4.48-2.tar.xz
# http://mirrors.kernel.org/sourceware/cygwin/x86_64/release/cygwin/cygwin-3.1.2-1.tar.xz
# http://mirrors.kernel.org/sourceware/cygwin/x86_64/release/coreutils/coreutils-8.26-2.tar.xz
# http://mirrors.kernel.org/sourceware/cygwin/x86_64/release/gmp/libgmp10/libgmp10-6.1.2-1.tar.xz
# http://mirrors.kernel.org/sourceware/cygwin/x86_64/release/ncurses/libncursesw10/libncursesw10-6.1-1.20190727.tar.xz
# http://mirrors.kernel.org/sourceware/cygwin/x86_64/release/bash/bash-4.4.12-3.tar.xz
# http://mirrors.kernel.org/sourceware/cygwin/x86_64/release/gcc/libstdc++6/libstdc++6-7.4.0-1.tar.xz
# EOF

mkdir -p dist
cd dist/
while read url; do
  echo "Getting $url"
  curl -O "$url"
  file="$(basename "$url")"
  tar --no-same-owner -xf "${file}"
  rm "${file}"
done <../urls.txt
zip -9r dist.zip .
find . -type d -exec rm -rf {} \;