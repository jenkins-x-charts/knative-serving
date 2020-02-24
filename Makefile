CHART_REPO := http://jenkins-x-chartmuseum:8080
NAME := knative-serving
OS := $(shell uname)
VERSION := 0.1.1
KNATIVE_VERSION := 0.12.1

CHARTMUSEUM_CREDS_USR := $(shell cat /builder/home/basic-auth-user.json)
CHARTMUSEUM_CREDS_PSW := $(shell cat /builder/home/basic-auth-pass.json)

init:
	helm init --client-only

setup: init
	helm repo add jenkinsxio http://chartmuseum.jenkins-x.io

download: clean
	cd knative-serving/templates && wget https://github.com/knative/serving/releases/download/v$(KNATIVE_VERSION)/serving-cert-manager.yaml
	cd knative-serving/templates && wget https://github.com/knative/serving/releases/download/v$(KNATIVE_VERSION)/serving-core.yaml
	cd knative-serving/templates && wget https://github.com/knative/serving/releases/download/v$(KNATIVE_VERSION)/serving-crds.yaml
	cd knative-serving/templates && wget https://github.com/knative/serving/releases/download/v$(KNATIVE_VERSION)/serving-hpa.yaml
	cd knative-serving/templates && wget https://github.com/knative/serving/releases/download/v$(KNATIVE_VERSION)/serving-istio.yaml
	cd knative-serving/templates && wget https://github.com/knative/serving/releases/download/v$(KNATIVE_VERSION)/serving-nscert.yaml

clean-templates:
	rm -rf knative-serving/templates/*.yaml

build: clean setup
	helm lint knative-serving

install: clean build
	helm upgrade ${NAME} knative-serving --install

upgrade: clean build
	helm upgrade ${NAME} knative-serving --install

delete:
	helm delete --purge ${NAME} knative-serving

clean:
	rm -rf knative-serving/charts
	rm -rf knative-serving/${NAME}*.tgz
	rm -rf knative-serving/requirements.lock

release: clean build
ifeq ($(OS),Darwin)
	sed -i "" -e "s/version:.*/version: $(VERSION)/" knative-serving/Chart.yaml

else ifeq ($(OS),Linux)
	sed -i -e "s/version:.*/version: $(VERSION)/" knative-serving/Chart.yaml
else
	exit -1
endif
	helm package knative-serving
	curl --fail -u $(CHARTMUSEUM_CREDS_USR):$(CHARTMUSEUM_CREDS_PSW) --data-binary "@$(NAME)-$(VERSION).tgz" $(CHART_REPO)/api/charts
	rm -rf ${NAME}*.tgz
