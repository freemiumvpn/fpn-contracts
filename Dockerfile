FROM golang:1.16-alpine AS STAGE_BUILD

ARG SERVICE

RUN apk update && apk add \
    protobuf \
    make \
    git

WORKDIR /go/src/github.com/freemiumvpn/${SERVICE}/

ADD . /go/src/github.com/freemiumvpn/${SERVICE}/

RUN make install
RUN make test
