.PHONY: build test lint docker run-local clean

build:
	go build -o bin/notify ./cmd/notify

test:
	go test ./... -v

lint:
	golangci-lint run ./...

docker:
	docker build -t gigvault/notify:local .

run-local: docker
	../infra/scripts/deploy-local.sh notify

clean:
	rm -rf bin/
	go clean
