# Stage 1: Build
FROM golang:1.23-bullseye AS builder

WORKDIR /src

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies (including shared v1.0.0 from GitHub)
RUN go mod download

# Copy source code
COPY . .

# Build the service
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o /app/notify ./cmd/notify

# Stage 2: Runtime
FROM alpine:3.18

# Install CA certificates for HTTPS
RUN apk --no-cache add ca-certificates

# Copy binary from builder
COPY --from=builder /app/notify /usr/local/bin/notify

# Copy config if exists
COPY config/ /config/ 2>/dev/null || true

# Expose ports
EXPOSE 8080 9090

# Run as non-root user
RUN adduser -D -u 1000 gigvault
USER gigvault

ENTRYPOINT ["/usr/local/bin/notify"]
