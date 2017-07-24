FROM ubuntu:16.04 AS devenv
WORKDIR /root

MAINTAINER Gonzalo Larralde <gonzalolarralde@gmail.com>

ADD util/prepare_environment/*.sh ./
ADD prefetched ./prefetched

COPY util/thin_image/environment-profile.sh /etc/profile.d/010-environment-profile.sh

RUN /bin/bash -e 010_install_dependencies.sh
RUN /bin/bash -e 020_install_ndk.sh
RUN /bin/bash -e 030_build_libiconv_libicu.sh
RUN /bin/bash -e 040_clone_last_swift.sh
RUN /bin/bash -e 050_build_swift_android.sh
RUN /bin/bash -e 060_build_corelibs_libdispatch.sh
RUN /bin/bash -e 070_build_corelibs_foundation.sh

CMD /bin/bash -l

FROM ubuntu:16.04 AS env
WORKDIR /root

COPY --from=devenv /root/swift-install /root/swift-install/
COPY --from=devenv /root/android-standalone-toolchain /root/android-standalone-toolchain/
COPY --from=devenv /etc/profile.d/010-environment-profile.sh /etc/profile.d/

ADD util/prepare_environment/010_install_dependencies.sh ./

RUN /bin/bash -e 010_install_dependencies.sh

CMD /bin/bash -l

