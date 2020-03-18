.PHONY: install

install:
	rm -f /usr/local/bin/gocryptmnt
	go get -v ./...
	go build -o /usr/local/bin/gocryptmnt gocryptmnt.go

uninstall:
	rm -f /usr/local/bin/gocryptmnt

docker:
	cd /go/src/github.com/thorko/gocryptmnt
	CGO_ENABLED=0 GOOS=linux go build -o /tmp/gocryptmnt gocryptmnt.go

test:
	/tmp/gocryptmnt --help
