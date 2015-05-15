### To build
# docker pull debian:jessie
# docker build -t netatalk-3.1.7 .
# docker run -it netatalk-3.1.7 /bin/bash
# # passwd user1
# # passwd user2
# # exit
# docker ps -a # to find the latest container
# docker commit XXXXXXXXXXXX netatalk-current # use the latest container
#
### To run
# docker run -it --net=host -v /var/log:/host/var_log -v /home:/host/home netatalk-current /bin/bash
# # /root/netatalk_start.sh
#
### To register
# cp netatalk.service /etc/systemd/system/multi-user.target.wants/
# systemctl enable netatalk

FROM debian:jessie

MAINTAINER tadakado@gmail.com

RUN cp -p /usr/share/zoneinfo/Asia/Tokyo /etc/localtime 
RUN echo Asia/Tokyo > /etc/timezone

RUN apt-get update
RUN apt-get upgrade -y

RUN apt-get install -y \
      automake avahi-daemon avahi-utils libnss-mdns tracker build-essential checkinstall libtool pkg-config net-tools procps wget less vim-tiny \
      libevent-dev libssl-dev libgcrypt11-dev libkrb5-dev libpam0g-dev libwrap0-dev libdb-dev libavahi-client-dev libacl1-dev libldap2-dev libcrack2-dev libdbus-1-dev libdbus-glib-1-dev libglib2.0-dev libtracker-sparql-1.0-dev libtracker-miner-1.0-dev

ADD debian_chroot /etc/

ADD netatalk.diff /usr/src/
RUN (cd /usr/src ;\
     wget http://prdownloads.sourceforge.net/netatalk/netatalk-3.1.7.tar.gz ;\
     tar -xvzf netatalk-3.1.7.tar.gz ;\
     patch -p 0 < netatalk.diff ;\
     cd /usr/src/netatalk-3.1.7 ;\
     ./configure \
       --with-init-style=debian-sysv \
       --without-acls \
       --without-ldap \
       --with-pam-confdir=/etc/pam.d \
       --with-dbus-sysconf-dir=/etc/dbus-1/system.d \
       --with-tracker-pkgconfig-version=1.0 ;\
     make && make install)

# RUN (cd /usr/src/netatalk-3.1.7 ;\
#      ./configure \
#        --with-init-style=debian-sysv \
#        --without-tdb \
#        --with-cracklib \
#        --enable-krbV-uam \
#        --with-pam-confdir=/etc/pam.d \
#        --with-dbus-sysconf-dir=/etc/dbus-1/system.d \
#        --with-tracker-pkgconfig-version=0.14)
#      make && make install)

# RUN (cd /usr/src/netatalk-3.1.7 ;\
#      ./configure \
#        --with-init-style=debian-sysv \
#        --with-pam-confdir=/etc/pam.d \
#        --with-dbus-sysconf-dir=/etc/dbus-1/system.d \
#        --with-tracker-pkgconfig-version=0.14)
#      make & make install)

ADD netatalk_*.sh /root/
ADD afp.conf /usr/local/etc/
RUN (mkdir -p /host/home /host/var_log ;\
     useradd -M -u 1000 -G nogroup user1 ;\
     useradd -M -u 1001 -G nogroup user2)
