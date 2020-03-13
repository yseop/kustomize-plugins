MAKEFILE_DIR := $(shell pwd)
PLUGINS_OUT=$(XDG_CONFIG_HOME)/kustomize/plugin
TEST_DIR=$(MAKEFILE_DIR)/test
BIN_DIR=$(MAKEFILE_DIR)/bin

# List of plugins to install
PLUGINS=git-secret
PLUGINS_TEST=$(PLUGINS:=-test)

all: setup $(PLUGINS)

test: $(PLUGINS_TEST)

setup:
	mkdir --parents $(BIN_DIR)
	curl --location http://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v$(KUSTOMIZE_VERSION)/kustomize_v$(KUSTOMIZE_VERSION)_linux_amd64.tar.gz | \
		tar --directory=$(BIN_DIR) --extract --gunzip --file -
	mkdir --parents $(PLUGINS_OUT)

git-secret:
	curl --location http://github.com/sobolevn/git-secret/archive/v$(GITSECRET_VERSION).tar.gz | \
		tar --extract --gunzip --file -
	$(MAKE) --directory=$(MAKEFILE_DIR)/git-secret-$(GITSECRET_VERSION)
	PREFIX="" DESTDIR=$(MAKEFILE_DIR) $(MAKE) --directory=$(MAKEFILE_DIR)/git-secret-$(GITSECRET_VERSION) install
	mkdir --parents $(PLUGINS_OUT)/yseop.com/v1alpha1/gitsecret
	cp -p plugin/yseop.com/v1alpha1/gitsecret/GitSecret $(PLUGINS_OUT)/yseop.com/v1alpha1/gitsecret/GitSecret

git-secret-test:
	gpg --import $(TEST_DIR)/gitsecret/sops_functional_tests_key.asc
	PATH="$(PATH):$(BIN_DIR)" XDG_CONFIG_HOME=$(XDG_CONFIG_HOME) kustomize build $(TEST_DIR)/gitsecret/base --enable_alpha_plugins
	PATH="$(PATH):$(BIN_DIR)" XDG_CONFIG_HOME=$(XDG_CONFIG_HOME) kustomize build $(TEST_DIR)/gitsecret/prod --enable_alpha_plugins

.PHONY: all setup $(PLUGINS) $(PLUGINS_TEST)
