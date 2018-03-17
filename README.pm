Full service secured/spam resistant SMTP server, with IMAP and SASL support as well.  Includes Spamassassin and Greylisting, with a local volume import for all of the secured configurations and email folders.

[minit](https://github.com/chazomaticus/minit) is an external dependency -- the included binary is just built from this project, for CentOS.

Components:

* Postfix (SMTP / SMTPS w/SASL)
* Dovecot (IMAPS)
* Spamassassin
* Greylisting
* rsyslog (cause postfix and others want to send to syslog, boo)
* TLS keys from letsencrypt.org

Note:

* The configurations for this are not stored here, due to security exposure.  If you would like a copy, feel free to ping me.
