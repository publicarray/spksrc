#!/bin/sh

# set -x
set -u

## build
# go get github.com/BurntSushi/toml
go build -ldflags "-s -w" -o index.cgi cgi.go

# compress
# upx --brute index.cgi

## test
export REQUEST_METHOD=GET
export SERVER_PROTOCOL=HTTP/1.1
./index.cgi --dev | head -35

export REQUEST_METHOD=POST
echo "ListenAddresses=0.0.0.0%3A1053+&ServerNames=cloudflare+google+ " | ./index.cgi --dev
echo "file=#############" | ./index.cgi --dev | tail -35