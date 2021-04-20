FROM ubuntu:20.04

RUN useradd -m -s /bin/bash -u 1000 dogecoin
RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y curl net-tools
RUN apt-get clean
RUN rm -rvf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV DOGECOIN_VERSION="1.14.3"
ENV DOGECOIN_DATA="/home/dogecoin/.dogecoin"
ENV PATH="/opt/dogecoin-${DOGECOIN_VERSION}/bin:${PATH}"

RUN curl -SLO "https://github.com/dogecoin/dogecoin/releases/download/v${DOGECOIN_VERSION}/dogecoin-${DOGECOIN_VERSION}-x86_64-linux-gnu.tar.gz"
RUN tar -xzf *.tar.gz -C /opt
RUN rm *.tar.gz
RUN rm -rf /opt/dogecoin-${DOGECOIN_VERSION}/bin/dogecoin-qt

WORKDIR /home/dogecoin
USER dogecoin
RUN mkdir .dogecoin
RUN chmod 700 .dogecoin

VOLUME ["${DOGECOIN_DATA}"]
EXPOSE 22556/tcp 22556/udp 22555/tcp 44556/tcp 44556/udp 44555/tcp
RUN dogecoind -version
CMD ["dogecoind", "-printtoconsole"]
