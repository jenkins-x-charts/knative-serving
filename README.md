# knative-serving

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

A helm chart for installing [knative serve](https://knative.dev/docs/serving/)

## Usage

If you are using [Jenkins X](https://jenkins-x.io/v3/about/) then add the following to your `helmfile.yaml`:

```yaml 
...
releases:
- chart: jx3/knative-serving
  version: 0.19.14
  name: knative-serving
  namespace: knative-serving
...
```

### Using Helm directly

[Helm](https://helm.sh) must be installed to use the charts.
Please refer to Helm's [documentation](https://helm.sh/docs/) to get started.

Once Helm is set up properly, add the repo as follows:

```bash 
helm repo add jx3 https://storage.googleapis.com/jenkinsxio/charts
```

you can then do

```bash
helm search repo knative-serving
```

The chart installs resources into the `knative-serving` namespace

