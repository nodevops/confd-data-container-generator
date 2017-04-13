FROM alpine

LABEL maintainer "Jules.Hablot@zenika.com"
LABEL maintainer "christophe.furmaniak@zenika.com"

RUN apk add --no-cache \
    python \
    python-dev \
    git

RUN mkdir -p /config/data
RUN mkdir -p /config/dictionaries

COPY setup/ /usr/local/bin/

VOLUME /config/

CMD ["create-conf.sh", "--out-directory=/config/", "--working-directory=/var/tmp/"]
