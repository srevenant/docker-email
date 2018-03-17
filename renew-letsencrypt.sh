#!/bin/bash

your_email=nobody@example.com
logfile=/root/renew-letsencrypt.log

cd /root

certbot=certbot

$certbot renew --no-self-upgrade > $logfile 2>&1 < /dev/null
status=$?
echo "status=$status" >> $logfile

if [ $status = 0 ]; then
    exit 0
fi

if nginx -t 2>/dev/null 1>&2; then
	systemctl restart nginx
fi

/data/mail/cpcert.sh

log=$(cat $logfile)
/usr/lib/sendmail -oi -t -f nobody@example.com  "nobody@example.com" <<END
From: Letsencrypt Renewal <nobody@example.com>
To: nobody@example.com
Subject: Lets Encrypt Renewal

$log
END

