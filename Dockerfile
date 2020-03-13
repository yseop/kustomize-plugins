FROM golang:1.13.4-alpine3.10

ARG GITSECRET_VERSION=0.3.2
ARG KUSTOMIZE_VERSION=3.5.4

WORKDIR /usr/app/

RUN apk add bash curl gawk gcc git gnupg make musl-dev tar

ENV GITSECRET_VERSION=$GITSECRET_VERSION
ENV KUSTOMIZE_VERSION=$KUSTOMIZE_VERSION
ENV XDG_CONFIG_HOME=/usr/app/
ENV PATH=$PATH:/usr/app/kustomize-plugins/bin

COPY . ./kustomize-plugins

# Install kustomize and plugins
RUN cd kustomize-plugins \
    && make all

ENTRYPOINT []
