#!/bin/bash

root=/usr/share/nginx/html # special case handling of this in .well-known

cd /root

certbot=certbot

reg() {
    site=$1
    $certbot certonly --webroot -w $root -d $site
}

for h in "$@"; do
    reg $h
done

