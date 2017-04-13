FROM alpine

RUN apk add --no-cache \
    python \
    python-dev \
    git

COPY setup/ /usr/local/bin/

RUN ./create-conf.sh
