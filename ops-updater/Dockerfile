FROM golang:1.21-alpine AS builder

RUN apk add --no-cache git

ENV GOPROXY=https://goproxy.cn,direct

WORKDIR /src
COPY . .

ARG TARGETARCH

RUN go mod init github.com/Cepave/ops-updater && go mod tidy && \
    CGO_ENABLED=0 GOOS=linux GOARCH=${TARGETARCH} \
    go build -ldflags="-s -w" -o /ops-updater .

