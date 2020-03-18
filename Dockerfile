FROM golang:alpine AS builder0
RUN apk add git && go get -v github.com/thorko/gocryptmnt
RUN cd /go/src/github.com/thorko/gocryptmnt && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o /tmp/gocryptmnt gocryptmnt.go

FROM golang:alpine AS builder1
RUN apk add git gcc libc-dev pkgconfig libressl-dev && go get -v github.com/rfjakob/gocryptfs
RUN cd /go/src/github.com/rfjakob/gocryptfs &&  sh ./build-without-openssl.bash

FROM alpine:latest
RUN apk --no-cache add ca-certificates
RUN apk add fuse
WORKDIR /root
COPY --from=builder0 /tmp/gocryptmnt /usr/local/bin/gocryptmnt
COPY --from=builder1 /go/src/github.com/rfjakob/gocryptfs/gocryptfs /usr/local/bin/gocryptfs
CMD ["/bin/sh"]
