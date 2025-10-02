# Build container
FROM golang:1.25 AS builder

RUN go version

RUN apt-get update && apt-get upgrade -y && apt-get install -y ca-certificates git zlib1g-dev

WORKDIR /go/src/github.com/TicketsBot-cloud
RUN git clone https://github.com/TicketsBot-cloud/worker.git
WORKDIR /go/src/github.com/TicketsBot-cloud/worker

RUN git submodule update --init --recursive --remote

RUN set -Eeux && \
    go mod download && \
    go mod verify

RUN GOOS=linux GOARCH=amd64 \
    go build \
    -tags=jsoniter \
    -trimpath \
    -o main cmd/registercommands/main.go

# Executable container
FROM ubuntu:latest

RUN apt-get update && apt-get upgrade -y && apt-get install -y ca-certificates curl

COPY --from=builder /go/src/github.com/TicketsBot-cloud/worker/locale /srv/worker/locale
COPY --from=builder /go/src/github.com/TicketsBot-cloud/worker/main /srv/worker/main

RUN chmod +x /srv/worker/main

RUN useradd -m container
USER container
WORKDIR /srv/worker

ENTRYPOINT ["/srv/worker/main"]