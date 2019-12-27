#!/usr/bin/env bash

which curl
which tar
pipenv run python -u get_cygwin_links.py | tee urls.txt

mkdir -p dist
cd dist/
while read url; do
  echo "Getting $url"
  curl -O "$url"
  file="$(basename "$url")"
  tar --no-same-owner -xf "${file}"
  #rm "${file}"
done <../urls.txt
zip -r ../dist.zip .