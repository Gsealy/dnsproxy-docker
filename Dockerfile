FROM hub.gsealy.net/docker/alpine:latest as builder
LABEL MAINTAINER Gsealy "gsealy@outlook.com"
LABEL VERSION 0.0.2

ARG BUILD_DATE
LABEL org.label-schema.build-date=$BUILD_DATE

ARG TARGETPLATFORM

EXPOSE 53

RUN set -ex \
    && sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
    && apk update \
    && apk upgrade \
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

FROM hub.gsealy.net/docker/alpine:latest
LABEL MAINTAINER Gsealy "gsealy@outlook.com"
COPY --from=builder /usr/bin/dnsproxy /usr/bin/dnsproxy

RUN set -ex \
    && sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
    && apk add --update --no-cache ca-certificates tzdata \
    && update-ca-certificates \
    && rm -rf /var/cache/apk/*

EXPOSE 53

ENV ARGS="-u https://doh-jp.blahdns.com/dns-query -u https://dns.google/dns-query -u https://doh.pub/dns-query -u https://223.5.5.5/dns-query -u quic://dot-sg.blahdns.com:784 -f 94.140.14.14:8853 -f 94.140.14.14:53 --all-servers --tls-min-version=1.2 --refuse-any -p 53 --cache --cache-min-ttl=30 --cache-max-ttl=300 --cache-optimistic"
ENV ARGS_SP="-u=[/github.com/]tcp://80.80.80.80 -u=[/githubassets.com/]tcp://80.80.80.80 -u=[/githubusercontent.com/]tcp://80.80.80.80"

CMD /usr/bin/dnsproxy ${ARGS} ${ARGS_SP}
