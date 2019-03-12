Full service secured/spam resistant SMTP server, with IMAP and SASL support as well.  Includes Spamassassin and Greylisting, with a local volume import for all of the secured configurations and email folders.

# Notes

* The configurations for this are not stored here, due to security exposure.  If you would like a copy, feel free to ping me.
* [minit](https://github.com/chazomaticus/minit) is an external dependency -- the included binary is just built from this project, for CentOS.

# Components

* Postfix (SMTP / SMTPS w/SASL)
* Dovecot (IMAPS)
* Spamassassin
* Greylisting
* rsyslog (cause postfix and others want to send to syslog, boo)
* TLS keys from letsencrypt.org

# Setup

* `/data/mail` is a root folder imported into the container, for persistent storage; you can find a skeleton of thi structure in this repo under data/mail.

    - update passwd,shadow,group files in `/data/mail/etc` which are then replicated into the
      running container, each time it starts (by the `startup` script).  An easy option is
      to login to the running container (`./demail-shell`) and run useradd, then copy the
      relevant bits back out to the source passwd/shadow/group files.  This will also create
      the user's home folder, which is useful.

* run as a service inside docker swarm, which assumes you have an external base folder of `/data/mail`--if youw ant to change that, update this stackfile as well.

```
docker swarm init
docker stack deploy -c docker-email.yml email
```

* Postfix configuration -- you will need to initialize all the postfix files with the defaults, you can leverate that stored in `data/mail/postfix` for additional help.  Replace `example.com` as appropriate for your own configuration.

* Crontab -- on the base host (outside the container) I have a few crontab jobs:

```
0 0 * * * /path-to-repo/spam-learn.cron
0 0 * * 6 /path-to-repo/rebuild-image.cron
0 0 * * * /path-to-repo/renew-letsencrypt.sh
```

* Letencrypt -- I run this on the base host, external to the container, but the renew/register scripts are included for reference.

* dkim: see configs in /etc/opendkim
   (used guide https://www.linode.com/docs/email/postfix/configure-spf-and-dkim-in-postfix-on-debian-8/ - tho I just used stock config).
    - his key size is too large for route53, so I dialed it down to 512k until it didn't have to be split up (which causes multiple DNS response error)
    - new domains:
        1. add to /etc/opendkim/*tables
        2. create keys with:
             cd /etc/opendkim/keys
             DOMAINS="pandim.xyz cold.org"
             KEYSIZE=1024
             for DOMAIN in $DOMAINS; do
                 DATE=$(date +%Y%m%d)
                 opendkim-genkey -b $KEYSIZE -h rsa-sha256 -r -s $DATE -d $DOMAIN -v
                 for suffix in txt private; do mv $DATE.$suffix $DOMAIN.$DATE.$suffix; ln -sf $DOMAIN.$DATE.$suffix $DOMAIN.$suffix; done
                 chown opendkim:opendkim /etc/opendkim/keys/*
             done
             # check with
             opendkim-testkey -d $DOMAIN -s $DATE -k $DOMAIN
        3. add .txt to dns; remove h=rsa-sha256 from entry (this causes errors)
