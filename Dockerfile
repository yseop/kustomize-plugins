FROM golang:1.13.4-alpine3.10 as builder

ARG GITSECRET_VERSION=0.3.2
ARG KUBESEC_VERSION=0.9.2
ARG KUSTOMIZE_VERSION=3.5.4

WORKDIR /usr/app/

RUN apk add bash curl gcc git make musl-dev tar

ENV GITSECRET_VERSION=$GITSECRET_VERSION
ENV KUBESEC_VERSION=$KUBESEC_VERSION
ENV KUSTOMIZE_VERSION=$KUSTOMIZE_VERSION
ENV XDG_CONFIG_HOME=/usr/app/
ENV PATH=$PATH:/usr/app/kustomize-plugins/bin

COPY . ./kustomize-plugins

# Install kustomize and plugins
RUN cd kustomize-plugins \
    && make all

ENTRYPOINT []

FROM alpine:latest

RUN apk --no-cache add bash ca-certificates gawk git gnupg
COPY --from=builder /go/bin/kustomize /usr/local/bin/
COPY --from=builder /usr/app/kustomize-plugins/bin/git-secret /usr/local/bin/
COPY --from=builder /usr/app/kustomize-plugins/bin/kubesec /usr/local/bin/

RUN addgroup -S kustomize \
    && adduser -S -s /bin/bash -u 1000 -G kustomize kustomize

USER 1000
ENV HOME=/home/kustomize
RUN mkdir --parents $HOME/.config
COPY --from=builder --chown=kustomize:kustomize /usr/app/kustomize $HOME/.config/kustomize
