FROM ubuntu:16.04
WORKDIR /root

MAINTAINER Gonzalo Larralde <gonzalolarralde@gmail.com>

ADD util/prepare_environment/*.sh ./

RUN /bin/bash 010_install_dependencies.sh
RUN /bin/bash 020_install_ndk.sh
RUN /bin/bash 030_build_libiconv_libicu.sh
RUN /bin/bash 040_clone_last_swift.sh
RUN /bin/bash 050_build_swift_android.sh
RUN /bin/bash 060_build_corelibs_libdispatch.sh
RUN /bin/bash 070_build_corelibs_foundation.sh

CMD /bin/bash -l
