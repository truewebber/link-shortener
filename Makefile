SHELL := /bin/bash

HELM_CHART_PATH = ./helm/link-shortener
RELEASE_NAME = link-shortener
PACKAGE_VERSION = 0.2.0
PACKAGE_DESTINATION := .
RESOLVED_VALUES_YAML := $(PACKAGE_DESTINATION)/values.resolved.yaml
APP_VERSION := $(shell git rev-parse HEAD)

all: upgrade clean

upgrade:
	@{ \
	CHART_NAME=$$(helm show chart $(HELM_CHART_PATH) | grep '^name:' | awk -F ': ' '{print $$2}'); \
	echo "$$CHART_NAME, Version: $(PACKAGE_VERSION), AppVersion: $(APP_VERSION)"; \
	vals eval -f $(HELM_CHART_PATH)/values.yaml > $(RESOLVED_VALUES_YAML); \
	helm package $(HELM_CHART_PATH) \
		--version $(PACKAGE_VERSION) \
		--app-version $(APP_VERSION) \
		--destination $(PACKAGE_DESTINATION); \
	CHART="$(PACKAGE_DESTINATION)/$$CHART_NAME-$(PACKAGE_VERSION).tgz"; \
	echo "Package: $$CHART"; \
	helm upgrade --install $(RELEASE_NAME) $$CHART -f $(RESOLVED_VALUES_YAML) --namespace apps --atomic --wait; \
	rm $(RESOLVED_VALUES_YAML); \
	}

clean:
	@rm -f $(PACKAGE_DESTINATION)/*-$(PACKAGE_VERSION).tgz
	@rm -f $(RESOLVED_VALUES_YAML)
