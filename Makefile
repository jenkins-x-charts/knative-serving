NAME := knative-serving
CHART_DIR := charts/${NAME}

KNATIVE_VERSION := 0.19.0
CHART_REPO := gs://jenkinsxio/charts

all: fetch build

fetch:
	rm -f ${CHART_DIR}/crds/*.yaml
	rm -f ${CHART_DIR}/templates/*.yaml
	curl -L https://github.com/knative/serving/releases/download/v${KNATIVE_VERSION}/serving-crds.yaml > ${CHART_DIR}/crds/resource.yaml
	curl -L https://github.com/knative/serving/releases/download/v${KNATIVE_VERSION}/serving-core.yaml > ${CHART_DIR}/templates/resource.yaml
	jx gitops split -d ${CHART_DIR}/crds
	jx gitops rename -d ${CHART_DIR}/crds
	jx gitops split -d ${CHART_DIR}/templates
	jx gitops rename -d ${CHART_DIR}/templates
	#cp src/templates/* ${CHART_DIR}/templates
	rm ${CHART_DIR}/templates/knative-serving-ns.yaml
	jx gitops helm escape -d ${CHART_DIR}/templates
	git add charts

build: clean
	rm -rf Chart.lock
	#helm dependency build
	helm lint ${CHART_DIR}

install: clean build
	helm install . --name ${NAME}

upgrade: clean build
	helm upgrade ${NAME} .

delete:
	helm delete --purge ${NAME}

clean:
	rm -rf ${NAME}*.tgz

release: clean
	helm repo add jx3 $(CHART_REPO)
	cd ${CHART_DIR} && helm dependency build && helm lint && helm package . && helm gcs push ${NAME}*.tgz jx3 --public && rm -rf ${NAME}*.tgz%

test:
	cd tests && go test -v

test-regen:
	cd tests && export HELM_UNIT_REGENERATE_EXPECTED=true && go test -v

