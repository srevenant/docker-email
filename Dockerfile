FROM centos:7
# revenant/centos7-hardened

EXPOSE 25/tcp 465/tcp 587/tcp 993/tcp

#VOLUME /app/python-3

COPY minit os-baseline.sh spam-learn /sbin/
COPY startup /etc/minit/startup

RUN yum -y install epel-release && \
    yum -y upgrade && \
    yum -y install rsyslog \
           postfix postgrey spamassassin \
           dovecot && \
    yum -y clean all && \
    localedef -i en_US -f UTF-8 en_US.UTF-8; \
    /root/os-baseline.sh; \
    cd /etc/; mv postfix postfix.old; ln -s /mail/etc/postfix postfix; \
    rm -f aliases; ln -s postfix/aliases; \
    cd /; rm -rf home; ln -s /mail/home home; \
    cd /var/spool; rm -rf postfix; ln -s /mail/spool postfix; \
    cd /etc/mail/spamassassin && \
      if [ -f local.cf ]; then mv local.cf local.cf.orig; fi && \
      ln -s /mail/spamassassin/local.cf

ARG BUILD_NUMBER
RUN echo $BUILD_NUMBER && yum -y upgrade && yum clean all

ENTRYPOINT ["/sbin/minit"]
