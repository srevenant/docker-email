#!/bin/bash

cat > /etc/rsyslog.conf <<END
\$WorkDirectory /var/lib/rsyslog
\$ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat
*.info;mail.none;authpriv.none;cron.none          @@172.31.18.101:514
authpriv.*                                        @@172.31.18.101:514
mail.*                                            @@172.31.18.101:514
END

cd /etc 
mv postfix postfix.old 
ln -s /postfix/etc/postfix postfix

cd /
rm -rf home
ln -s /postfix/home home

cd /var/spool
rm -rf postfix
ln -s /postfix/spool postfix

