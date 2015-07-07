FROM ubuntu:14.04

#Maintainer
MAINTAINER whatwedo GmbH <welove@whatwedo.ch>

#Base settings
ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root

#Prevent initramfs updates from trying to run grub and lilo.
#https://journal.paul.querna.org/articles/2013/10/15/docker-ubuntu-on-rackspace/
#http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=594189
RUN export INITRD=no
RUN mkdir -p /etc/container_environment
RUN echo -n no > /etc/container_environment/INITRD

## Enable Ubuntu Universe and Multiverse.
RUN sed -i 's/^#\s*\(deb.*universe\)$/\1/g' /etc/apt/sources.list
RUN sed -i 's/^#\s*\(deb.*multiverse\)$/\1/g' /etc/apt/sources.list

#Update system
RUN apt-get update -y
RUN apt-get upgrade -y

#Install HTTPS support for APT
RUN apt-get install -y apt-transport-https ca-certificates software-properties-common

#Fix locales
RUN apt-get install -y language-pack-en
RUN locale-gen en_US
RUN update-locale LANG=en_US.UTF-8 LC_CTYPE=en_US.UTF-8
RUN echo -n en_US.UTF-8 > /etc/container_environment/LANG
RUN echo -n en_US.UTF-8 > /etc/container_environment/LC_CTYPE
RUN apt-get install localepurge

#Fix: TERM environment variable not set.
ENV TERM dumb

#Create upstart script
RUN echo "#\0041/bin/bash" > /bin/upstart
RUN chmod 755 /bin/upstart

#Add firstbootscript
ADD files/firstboot /bin
RUN echo "/bin/firstboot" >> /bin/upstart
RUN chmod 755 /bin/firstboot

#Set upstart script
CMD /bin/upstart

#Set motd
ADD files/motd /etc

#Install often used tools
RUN apt-get install -y curl less nano wget unzip