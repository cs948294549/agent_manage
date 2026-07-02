FROM golang:1.21-alpine AS builder

RUN apk add --no-cache git

ENV GOPROXY=https://goproxy.cn,direct

WORKDIR /src
COPY . .

RUN case $(uname -m) in \
        x86_64)  GOARCH=amd64 ;; \
        aarch64) GOARCH=arm64 ;; \
        armv7l)  GOARCH=arm ;; \
        *)       echo "unsupported arch: $(uname -m)" && exit 1 ;; \
    esac && \
    go mod init github.com/Cepave/ops-updater && go mod tidy && \
    CGO_ENABLED=0 GOOS=linux GOARCH=${GOARCH} \
    go build -ldflags="-s -w" -o /ops-updater-https .

