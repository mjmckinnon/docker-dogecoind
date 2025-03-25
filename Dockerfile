FROM mjmckinnon/ubuntubuild:22.04 AS builder

ARG VERSION="v1.14.9"
ARG GITREPO="https://github.com/dogecoin/dogecoin.git"
ARG GITNAME="dogecoin"
ARG COMPILEFLAGS="--disable-tests --disable-bench --enable-cxx --disable-shared --with-pic --disable-wallet --without-gui --without-miniupnpc"
ENV DEBIAN_FRONTEND="noninteractive"

# Get the source from Github
WORKDIR /root
RUN git clone ${GITREPO} --branch ${VERSION}

# Run the build script under /root/dogecoin/
WORKDIR /root/${GITNAME}
COPY build.sh .
RUN chmod +x ./build.sh && ./build.sh "$VERSION" "$COMPILEFLAGS"

# Final stage
FROM ubuntu:22.04
LABEL maintainer="Michael J. McKinnon <mjmckinnon@gmail.com>"

# Put our entrypoint script in
COPY ./docker-entrypoint.sh /usr/local/bin/

# Copy the compiled files
COPY --from=builder /dist-files/ /

ENV DEBIAN_FRONTEND="noninteractive"
RUN set -e \
    && echo "** update and install dependencies ** " \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
       gosu \
       libboost-filesystem1.83.0 \
       libboost-thread1.83.0 \
       libevent-2.1-7t64 \
       libevent-pthreads-2.1-7t64 \
       libboost-program-options1.83.0 \
       libboost-chrono1.83.0 \
       libzmq3-dev \
    && apt-get clean autoclean \
    && apt-get autoremove --yes \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ \
    && rm -rf /tmp/* /var/tmp/*

RUN \
    echo "** setup the dogecoin user **" \
    && groupadd -r dogecoin \
    && useradd --no-log-init -m -d /data -r -g dogecoin dogecoin

ENV DATADIR="/data"
EXPOSE 22556
VOLUME /data

USER dogecoin
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["dogecoind", "-printtoconsole"]
