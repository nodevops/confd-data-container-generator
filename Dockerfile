FROM alpine

LABEL maintainer "Jules.Hablot@zenika.com" \
      maintainer "christophe.furmaniak@zenika.com"

RUN apk add --no-cache \
    bash \
    python \
    git

COPY setup/ /usr/local/bin/

ARG WORKDIR=/var/tmp/
ARG OUTDIR=/config
ARG REPOSITORY=https://gitlab.com/cfurmaniak/guestbook-configuration-confd.git
ARG VERSION=v0.1.1
ARG ENVIRONMENT=dev-local
ARG CONFIG_FILE_NAME=env.sh

ENV OUTDIR=$OUTDIR \
    REPOSITORY=$REPOSITORY \
    VERSION=$VERSION \
    ENVIRONMENT=$ENVIRONMENT \
    CONFIG_FILE_NAME=$CONFIG_FILE_NAME

RUN mkdir -p $OUTDIR/data $OUTDIR/dictionaries

RUN create-conf.sh \
        --out-directory=$OUTDIR \
        --working-directory=$WORKDIR \
        --repository=$REPOSITORY \
        --app-version=$VERSION \
        --environment=$ENVIRONMENT \
        --config-file-name=$CONFIG_FILE_NAME

VOLUME $OUTDIR
