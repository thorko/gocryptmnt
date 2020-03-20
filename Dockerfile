FROM golang:alpine AS builder0
RUN apk add git && go get -v github.com/thorko/gocryptmnt
RUN cd /go/src/github.com/thorko/gocryptmnt && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o /tmp/gocryptmnt gocryptmnt.go

FROM golang:alpine AS builder1
RUN apk add git gcc libc-dev pkgconfig libressl-dev && go get -v github.com/rfjakob/gocryptfs
RUN cd /go/src/github.com/rfjakob/gocryptfs &&  sh ./build-without-openssl.bash

FROM alpine:latest AS builder2
RUN apk update && \
apk add g++ git busybox automake fuse-dev gnutls-dev make autoconf curl-dev libxml2-dev && \
git clone https://github.com/s3fs-fuse/s3fs-fuse.git /tmp/s3fs-fuse &&  \
cd /tmp/s3fs-fuse && ./autogen.sh && ./configure && make && make install

FROM alpine:latest
RUN apk --no-cache add ca-certificates
RUN apk add fuse libxml2 libcurl libstdc++
WORKDIR /root
COPY --from=builder0 /tmp/gocryptmnt /usr/bin/gocryptmnt
COPY --from=builder1 /go/src/github.com/rfjakob/gocryptfs/gocryptfs /usr/bin/gocryptfs
COPY --from=builder2 /usr/local/bin/s3fs /usr/bin/s3fs
CMD ["/bin/sh"]
