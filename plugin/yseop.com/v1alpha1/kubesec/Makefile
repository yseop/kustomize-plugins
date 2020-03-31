GO = go
GO_FLAGS = -buildmode plugin
GO_LD_FLAGS = -s -w
GO_FILES := $(shell find . -name '*.go' | grep -v /vendor/)

export GO111MODULE = on

KUSTOMIZE_VERSION?=3.5.4

all: clean kustomize build

clean:
	$(GO) clean -i ./...

fmt:
	$(GO) fmt -i ./...

kustomize:
	$(GO) get "sigs.k8s.io/kustomize/kustomize/v3@v$(KUSTOMIZE_VERSION)"

build:
	$(GO) build -o Kubesec.so $(GO_FLAGS) -ldflags "$(GO_LD_FLAGS)" ./...

unit-test:
	$(GO) test

.PHONY: clean fmt build unit-test
