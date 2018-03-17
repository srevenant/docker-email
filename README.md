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

* run as a service inside docker swarm:

```
docker swarm init
docker stack deploy -c docker-email.yml email
```

* `/data/mail` is a root folder imported into the container, for persistent storage; you can find a skeleton of thi structure in this repo under data/mail.

    - update passwd,shadow,group files in `/data/mail/etc` which are then replicated into the
      running container, each time it starts (by the `startup` script).  An easy option is
      to login to the running container (`./demail-shell`) and run useradd, then copy the
      relevant bits back out to the source passwd/shadow/group files.  This will also create
      the user's home folder, which is useful.

* Postfix configuration -- you will need to initialize all the postfix files with the defaults, you can leverate that stored in `data/mail/postfix` for additional help.  Replace `example.com` as appropriate for your own configuration.

* Crontab -- on the base host (outside the container) I have a few crontab jobs:

```
0 0 * * * /path-to-repo/spam-learn.cron
0 0 * * 6 /path-to-repo/rebuild-image.cron
0 0 * * * /path-to-repo/renew-letsencrypt.sh
```

* Letencrypt -- I run this on the base host, external to the container, but the renew/register scripts are included for reference.

