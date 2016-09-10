FROM revenant/centos7-hardened

EXPOSE 25/tcp 465/tcp 587/tcp 110/tcp 143/tcp 993/tcp 995/tcp

RUN cat /etc/resolv.conf

RUN find /etc/yum.repos.d

RUN yum -y install epel-release
RUN yum -y install rsyslog \
           postfix postgrey spamassassin \
           dovecot dovecoat-imapd && yum clean all

VOLUME /mail

RUN cd /etc/; mv postfix postfix.old; ln -s /mail/etc/postfix postfix; \
	rm -f aliases; ln -s postfix/aliases; \
	cd /; rm -rf home; ln -s /mail/home home; \
	cd /var/spool; rm -rf postfix; ln -s /mail/spool postfix

ADD startup /etc/minit/startup

ENTRYPOINT ["/sbin/minit"]
