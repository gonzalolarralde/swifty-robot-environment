FROM ubuntu:16.04
WORKDIR /root

MAINTAINER Gonzalo Larralde <gonzalolarralde@gmail.com>

ADD output.tar.gz ./
COPY environment-profile.sh /etc/profile.d/010-environment-profile.sh

RUN apt-get -y update && apt-get install -y \
    git cmake ninja-build clang python uuid-dev libicu-dev icu-devtools \
    libbsd-dev libedit-dev libxml2-dev libsqlite3-dev swig libpython-dev \
    libncurses5-dev pkg-config libblocksruntime-dev libcurl4-openssl-dev \
    autoconf automake libtool curl wget unzip

CMD /bin/bash -l
