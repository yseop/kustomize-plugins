MAKEFILE_DIR := $(shell pwd)
XDG_CONFIG_HOME?=$(MAKEFILE_DIR)
PLUGINS_OUT=$(XDG_CONFIG_HOME)/kustomize/plugin
TEST_DIR=$(MAKEFILE_DIR)/test
BIN_DIR=$(MAKEFILE_DIR)/bin

# List of plugins to install
PLUGINS=git-secret kubesec
PLUGINS_TEST=$(PLUGINS:=-test)

# Default versions
GITSECRET_VERSION?=0.3.2
KUBESEC_VERSION?=0.9.2
KUSTOMIZE_VERSION?=3.5.4

all: setup $(PLUGINS)

test: $(PLUGINS_TEST)

setup:
	mkdir --parents $(BIN_DIR)
	mkdir --parents $(PLUGINS_OUT)
	GO111MODULE=on go get sigs.k8s.io/kustomize/kustomize/v3@v$(KUSTOMIZE_VERSION)

git-secret:
	curl --location http://github.com/sobolevn/git-secret/archive/v$(GITSECRET_VERSION).tar.gz | \
		tar --extract --gunzip --file -
	$(MAKE) --directory=$(MAKEFILE_DIR)/git-secret-$(GITSECRET_VERSION)
	PREFIX="" DESTDIR=$(MAKEFILE_DIR) $(MAKE) --directory=$(MAKEFILE_DIR)/git-secret-$(GITSECRET_VERSION) install
	mkdir --parents $(PLUGINS_OUT)/yseop.com/v1alpha1/gitsecret
	cp -p plugin/yseop.com/v1alpha1/gitsecret/GitSecret $(PLUGINS_OUT)/yseop.com/v1alpha1/gitsecret/GitSecret

git-secret-test:
	gpg --import $(TEST_DIR)/gitsecret/sops_functional_tests_key.asc
	for DIR in base prod; do \
		PATH="$(PATH):$(BIN_DIR)" XDG_CONFIG_HOME=$(XDG_CONFIG_HOME) kustomize build $(TEST_DIR)/gitsecret/$(DIR) --enable_alpha_plugins \
	done;

kubesec:
	curl --location --silent --show-error https://github.com/shyiko/kubesec/releases/download/$(KUBESEC_VERSION)/kubesec-$(KUBESEC_VERSION)-linux-amd64 -o ${BIN_DIR}/kubesec
	chmod a+x ${BIN_DIR}/kubesec
	mkdir --parents $(PLUGINS_OUT)/yseop.com/v1alpha1/kubesec
	KUSTOMIZE_VERSION=$(KUSTOMIZE_VERSION) $(MAKE) -C plugin/yseop.com/v1alpha1/kubesec
	cp -p plugin/yseop.com/v1alpha1/kubesec/Kubesec.so $(PLUGINS_OUT)/yseop.com/v1alpha1/kubesec/Kubesec.so

kubesec-test:
	for DIR in base prod; do \
		PATH="$(PATH):$(BIN_DIR)" XDG_CONFIG_HOME=$(XDG_CONFIG_HOME) kustomize build $(TEST_DIR)/kubesec/$(DIR) --enable_alpha_plugins \
	done;

.PHONY: all setup $(PLUGINS) $(PLUGINS_TEST)
