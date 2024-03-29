FROM centos:7
MAINTAINER "Roman Pavlyuk" <roman.pavlyuk@gmail.com>

ENV container docker

RUN yum install -y epel-release

RUN yum update -y

RUN yum install -y less file mc vim-enhanced telnet net-tools which bash-completion openssh-clients

### Let's enable systemd on the container
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]

# Install Python3.6 environment
RUN yum install -y python36 python36-pip
RUN pip3 install --upgrade pip

# Install Pyramid framework
RUN pip3 install lifesospy_mqtt

# Setup journa;d
VOLUME ["/var/log/journal"]
COPY ./src/systemd/journald.conf /etc/systemd/journald.conf

# Copy configs
VOLUME ["/lifesospy_mqtt"]
COPY ./src/lifesospy_mqtt /lifesospy_mqtt
RUN ls -l /lifesospy_mqtt/

# Install the service
COPY ./src/lifesospy_mqtt/lifesospy_mqtt.service /usr/lib/systemd/system/lifesospy_mqtt.service

# Enable the service
RUN systemctl enable lifesospy_mqtt.service

# Install service monitor
COPY ./src/logmon/logmon.sh /usr/local/bin/logmon.sh
RUN chmod +x /usr/local/bin/logmon.sh
COPY ./src/logmon/logmon-lifesospy_mqtt.service /usr/lib/systemd/system/logmon-lifesospy_mqtt.service
RUN systemctl enable logmon-lifesospy_mqtt.service

# Install cron file to restart log monitor because of log file rotation
RUN yum install -y cronie
RUN systemctl enable crond.service
COPY ./src/cron.d/* /etc/cron.d/
RUN chmod 600 /etc/cron.d/restart-logmon-lifesospy_mqtt

#CMD ["lifesospy_mqtt", "-l", "-p", "--configfile", "/lifesospy_mqtt/config.yaml", "--logfile", "/lifesospy_mqtt/log", "--pidfile", "/lifesospy_mqtt/pid"]

### Kick it off
CMD ["/usr/sbin/init"]
