FROM golang:1.15-alpine AS STAGE_BUILD

ARG SERVICE

RUN apk update && apk add \
    protobuf \
    make \
    git \
    protobuf-dev \
    clang

WORKDIR /go/src/github.com/freemiumvpn/${SERVICE}/

ADD . /go/src/github.com/freemiumvpn/${SERVICE}/

RUN make install
RUN make test
