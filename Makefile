.PHONY: install

install:
	rm -f /usr/local/bin/gocryptmnt
	go get -v ./...
	go build -o /usr/local/bin/gocryptmnt gocryptmnt.go

uninstall:
	rm -f /usr/local/bin/gocryptmnt

docker:
	go get -v github.com/thorko/gocryptmnt

test:
	/tmp/gocryptmnt --help
