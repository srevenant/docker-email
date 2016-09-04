FROM hardened-centos

EXPOSE 25/tcp 465/tcp 587/tcp 110/tcp 143/tcp 993/tcp 995/tcp

RUN yum -y install epel-release \
		   rsyslog \
           postfix postgrey spamassassin \
           dovecot dovecoat-imapd && yum clean all

VOLUME /postfix

COPY setup.sh /root
RUN bash /root/setup.sh; rm -f /root/setup.sh

ADD startup /etc/minit/startup

ENTRYPOINT ["/sbin/minit"]
