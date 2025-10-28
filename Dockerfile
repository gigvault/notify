FROM golang:1.23-bullseye AS builder
WORKDIR /src

# Copy shared library first
COPY shared/ ./shared/

# Copy service files
COPY notify/go.mod notify/go.sum ./notify/
WORKDIR /src/notify
RUN go mod download

WORKDIR /src
COPY notify/ ./notify/
WORKDIR /src/notify
RUN CGO_ENABLED=0 GOOS=linux go build -o /out/notify ./cmd/notify

FROM alpine:3.18
RUN apk add --no-cache ca-certificates
COPY --from=builder /out/notify /usr/local/bin/notify
COPY notify/config/ /config/
EXPOSE 8080 9090
ENTRYPOINT ["/usr/local/bin/notify"]
