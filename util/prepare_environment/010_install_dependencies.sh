#### swifty-robot-environment ####
#
# Gets dependencies required to build the environment
#
# Version 0.1 (2016-09-12)
#

apt-get -y update && apt-get install -y \
	git cmake ninja-build clang python uuid-dev libicu-dev icu-devtools \
	libbsd-dev libedit-dev libxml2-dev libsqlite3-dev swig libpython-dev \
	libncurses5-dev pkg-config libblocksruntime-dev libcurl4-openssl-dev \
	autoconf automake libtool curl wget unzip
