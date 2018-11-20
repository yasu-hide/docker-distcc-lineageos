FROM ubuntu:16.04 AS aosp
ENV DEBIAN_FRONTEND noninteractive
ENV VERSION_ANDROID android-9.0.0_r16
RUN apt-get update && apt-get install -y git \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /lineage/src/prebuilts/clang/host \
    && git clone -b $VERSION_ANDROID https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/ /lineage/src/prebuilts/clang/host/linux-x86 \
    && (cd /lineage/src/prebuilts/clang/host/linux-x86/clang-4691093/bin \
        && mv clang clang-wrapper && ln -s clang.real clang \
        && mv clang++ clang++-wrapper && ln -s clang++.real clang++ \
        && cd -) \
    && rm -rf /lineage/src/prebuilts/clang/host/linux-x86/.git
RUN mkdir -p /lineage/src/prebuilts/gcc/linux-x86/host \
    && git clone -b $VERSION_ANDROID https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/host/x86_64-linux-glibc2.15-4.8 /lineage/src/prebuilts/gcc/linux-x86/host/x86_64-linux-glibc2.15-4.8 \
    && mv /lineage/src/prebuilts/gcc/linux-x86/host/x86_64-linux-glibc2.15-4.8/bin /lineage/src/prebuilts/gcc/linux-x86/host/x86_64-linux-glibc2.15-4.8/bin.real \
    && mkdir /lineage/src/prebuilts/gcc/linux-x86/host/x86_64-linux-glibc2.15-4.8/bin \
    && (cd /lineage/src/prebuilts/gcc/linux-x86/host/x86_64-linux-glibc2.15-4.8/bin && ln -s ../bin.real/* . && cd -) \
    && mv /lineage/src/prebuilts/gcc/linux-x86/host/x86_64-linux-glibc2.15-4.8/x86_64-linux/bin /lineage/src/prebuilts/gcc/linux-x86/host/x86_64-linux-glibc2.15-4.8/x86_64-linux/bin.real \
    && mkdir /lineage/src/prebuilts/gcc/linux-x86/host/x86_64-linux-glibc2.15-4.8/x86_64-linux/bin \
    && (cd /lineage/src/prebuilts/gcc/linux-x86/host/x86_64-linux-glibc2.15-4.8/x86_64-linux/bin && ln -s ../bin.real/* . && cd -) \
    && rm -rf /lineage/src/prebuilts/gcc/linux-x86/host/x86_64-linux-glibc2.15-4.8/.git
RUN mkdir -p /lineage/src/prebuilts/gcc/linux-x86/arm \
    && git clone -b $VERSION_ANDROID https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9 /lineage/src/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9 \
    && rm -rf /lineage/src/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/.git


FROM ubuntu:16.04
ENV DEBIAN_FRONTEND noninteractive
ENV USE_CCACHE 1
ENV CCACHE_SIZE "50G"
ENV CCACHE_COMPRESS 1
ENV CCACHE_DIR /ccache
ENV CCACHE_PREFIX distcc
ENV DISTCCD_PATH=/lineage/src

RUN apt-get update && apt-get install -y \
    ccache distcc python \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
COPY --from=aosp /lineage/src/prebuilts $DISTCCD_PATH/prebuilts
RUN ccache -M $CCACHE_SIZE && ccache -s
WORKDIR $DISTCCD_PATH
ENV TMPDIR=$DISTCCD_PATH
ENTRYPOINT ["/usr/bin/distccd"]
CMD ["--verbose","--log-stderr","--no-detach","--user","distccd","--allow","0.0.0.0/0"]
EXPOSE 3632
