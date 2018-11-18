FROM ubuntu:16.04
ENV DEBIAN_FRONTEND noninteractive
ENV USE_CCACHE 1
ENV CCACHE_SIZE "50G"
ENV CCACHE_COMPRESS 1
ENV CCACHE_DIR /ccache
ENV CCACHE_PREFIX distcc

RUN apt-get update && apt-get install -y \
    ccache distcc clang build-essential \
    && apt-get -y remove gcc g++ \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-3.8 50 && \
    update-alternatives --install /usr/bin/cc cc /usr/bin/clang-3.8 50
RUN ccache -M $CCACHE_SIZE && ccache -s
WORKDIR $CCACHE_DIR
ENTRYPOINT ["/usr/bin/distccd"]
CMD ["--log-stderr","--no-detach","--user","distccd","--allow","0.0.0.0/0"]
EXPOSE 3632
