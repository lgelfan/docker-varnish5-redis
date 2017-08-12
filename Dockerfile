####
# Varnish 5.1 on Ubuntu
# docker build -t varnish5:develop .
#

FROM ubuntu:16.04
MAINTAINER lars@float.com

EXPOSE 6081 6082

ENV VARNISH_VER 5.1
ENV VARNISH_MEMORY_SIZE 256m
# ENV VARNISH_STORAGE_SIZE 512m

RUN apt-get update
RUN apt-get install -y curl nano zip libev-dev
RUN curl -s https://packagecloud.io/install/repositories/varnishcache/varnish51/script.deb.sh | bash

RUN apt-get install -y varnish
COPY default.vcl /etc/varnish/default.vcl

# ENV CACHBUST=4
COPY libs /tmp

RUN cd /usr/lib/varnish && tar -xf /tmp/vmods51.tar
RUN cd /usr/local/lib && tar -xf /tmp/hiredis-lib.tar --strip-components=1
RUN ln -s /usr/local/lib/libhiredis.so.0.13 /usr/lib && ldconfig

ENTRYPOINT varnishd -f /etc/varnish/default.vcl -s malloc,${VARNISH_MEMORY_SIZE} -a 0.0.0.0:6081 -F
