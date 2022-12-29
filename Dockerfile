FROM alpine:latest
LABEL MAINTAINER Gsealy "gsealy@outlook.com"
LABEL VERSION 0.0.1

ARG BUILD_DATE
LABEL org.label-schema.build-date=$BUILD_DATE

ARG TARGETPLATFORM

EXPOSE 53

RUN apk update
RUN apk upgrade

RUN set -ex \
    && sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
    && apk add --update --no-cache curl wget ca-certificates jq tzdata \
    && update-ca-certificates \
    && rm -rf /var/cache/apk/*

# /usr/bin/dnsproxy
RUN if [ "$TARGETPLATFORM" == "linux/amd64" ]; then cd /tmp \
    && curl -skSL $(curl -skSL 'https://api.github.com/repos/AdguardTeam/dnsproxy/releases/latest' | sed -n '/url.*linux-amd64/{s/.*\(https:.*tar.gz\).*/\1/p}') | tar xz \
    && mv linux-amd64/dnsproxy /usr/bin/ \
    && dnsproxy --version \
    && rm -rf /tmp/*; fi

RUN if [ "$TARGETPLATFORM" == "linux/arm64" ]; then cd /tmp \
    && curl -skSL $(curl -skSL 'https://api.github.com/repos/AdguardTeam/dnsproxy/releases/latest' | sed -n '/url.*linux-amd64/{s/.*\(https:.*tar.gz\).*/\1/p}') | tar xz \
    && mv linux-amd64/dnsproxy /usr/bin/ \
    && dnsproxy --version \
    && rm -rf /tmp/*; fi

ENV ARGS="-u=https://doh-jp.blahdns.com/dns-query -u https://dns.google/dns-query -u https://223.5.5.5/dns-query -u quic://dot-sg.blahdns.com:784 -f 94.140.14.14:53 -f 94.140.14.14:8853 -b 9.9.9.9:9953 -b 9.9.9.9:53 --all-servers --tls-min-version=1.2 --refuse-any -p 53 --cache --cache-min-ttl=30 --cache-max-ttl=300 --cache-optimistic --edns"

ENV ARGS_SP="-u=[/github.com/]tcp://80.80.80.80 -u=[/githubassets.com/]tcp://80.80.80.80 -u=[/githubusercontent.com/]tcp://80.80.80.80"

CMD /usr/bin/dnsproxy ${ARGS} ${ARGS_SP}
