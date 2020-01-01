#!/usr/bin/env bash

pipenv run python -u get_cygwin_links.py $1 > urls.txt

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
rm -rf *
cp ../build.sh .

echo "Creating directory hierarchy"
mkdir -p bin
mkdir -p lib
mkdir -p home
mkdir -p tmp
mkdir -p usr
ln -s ../bin usr/bin
ln -s ../lib usr/lib

while read url; do
  echo "Getting $url"
  export _url=$url
  bash <<CMD &
    curl -sO "\${_url}"
    file="\$(basename "\${_url}")"
    tar --no-same-owner -hxf "\${file}"
    rm "\${file}"
CMD
done <../urls.txt

echo "Waiting for downloads to finish"
for p in $(jobs -p); do
  wait $p
done

# echo "Downloading python dependencies"
# mkdir -p vendor
# cd vendor
# pip download -r ../../requirements.txt

# echo "Replacing Linux wheels with source"
# touch requirements-no-binary.txt
# find . -name "*.whl" | xargs -n 1 basename | grep -vE "none-any.whl$" | grep -Po ".*?(?=-[0-9])" > requirements-no-binary.txt
# pip download --no-binary :all: -r requirements-no-binary.txt
# cat requirements-no-binary.txt | xargs -n 1 -I{} bash -c 'rm {}*.whl'
# cd ..

echo "Zipping files"
# zip -5qr dist.zip .
tar acf dist.tar.gz .

# find . -type d | grep -v "^." | xargs -r rm -rf
