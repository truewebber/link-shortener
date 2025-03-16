HELM_CHART_PATH = ./helm/link-shortener
RELEASE_NAME = link-shortener
PACKAGE_VERSION = 0.1.0
PACKAGE_DESTINATION = .
APP_VERSION := $(shell git rev-parse HEAD)

all: upgrade clean

upgrade:
	@CHART_NAME=$$(helm show chart $(HELM_CHART_PATH) | grep 'name:' | awk -F ': ' '{print $$2}') && \
	echo "$$CHART_NAME, Version: $(PACKAGE_VERSION), AppVersion: $(APP_VERSION)" && \
	helm package $(HELM_CHART_PATH) --version $(PACKAGE_VERSION) --app-version $(APP_VERSION) --destination $(PACKAGE_DESTINATION) && \
	CHART="$(PACKAGE_DESTINATION)/$$CHART_NAME-$(PACKAGE_VERSION).tgz" && \
	helm upgrade --install $(RELEASE_NAME) $$CHART --namespace apps --wait;

clean:
	@rm $(PACKAGE_DESTINATION)/*-$(PACKAGE_VERSION).tgz
