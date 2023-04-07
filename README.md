# metaflow-helm-charts

Helm Chart to make deploying Metaflow on kubernetes as easy as possible.

These charts are aimed first at teams who want to get a development Metaflow stack running as fast as possible. This project provides charts for the following:

- [Metaflow UI](https://github.com/Netflix/metaflow-ui)
- [Metaflow Service](https://github.com/Netflix/metaflow-service)
- [Metaflow itself](https://github.com/Netflix/metaflow)

It also integrates with a few other cool projects to improve the developer experience:

- [Kubegres](https://github.com/reactive-tech/kubegres)
- [Minio](https://github.com/minio/minio)

Once the goal of delivering a kubernetes-native Metaflow deployment is mature, we will begin rolling additional features to this chart that will allow integrations directly with infrastructure on AWS, Azure, and GCP so that you can use the same helm chart regardless of where your infrastructure lives.

## Getting Started

### Dependencies

These Custom Resource Definitions should be installed prior to `helm install`-ing this chart. A link and description to what each CRD does can be found below.

| Link                                 | Description                                                                  |
| ------------------------------------ | ---------------------------------------------------------------------------- |
| [Kubegres](https://www.kubegres.io/) | Kubernetes Operator that provides highly-available deployments of Postgresql |
|                                      |                                                                              |

#### Kubegres

Kubegres provides a kubernetes operator that allows for highly-available and highly-scalable PostgreSQL deployments on kubernetes. Often folks avoid putting databases on kubernetes because you need to manage things like backups, primary/secondary failover(s), etc. Reaching for AWS RDS is usually simpler, but Kubegres now provides a CRD `kind: Kubegres` that handles a lot of these problems out of the box.

```bash
export KUBEGRES_VERSION=1.16
kubectl apply -f https://raw.githubusercontent.com/reactive-tech/kubegres/v$KUBEGRES_VERSION/kubegres.yaml

```

#### Secret

Now you will need to provide passwords for both the Primary and Replica databases that will be deployed. You can do so either manually in the helm chart via `.Values.global.superUserPassword` & `.Values.global.replicationUserPassword`, or you can define a Kubernetes Secret and provide that secret name at `.Values.global.secretName`. I recommend creating the Kubernetes Secret object, this will look something like this:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-cool-secret
stringData:
  superUserPassword: "password123"
  replicationUserPassword: "password234"
```

Then inside your `values.yaml` file you will supply the name of the secret like so:

```yaml
global:
  secrets:
    secretName: my-cool-secret
```

#### Istio

Installing [Istio via Helm](https://istio.io/latest/docs/setup/install/helm/).

1. Create `istio-system` Namespace.
  - `kubectl create namespace istio-system`
2. Install `istio-base`.
  - `helm install istio-base istio/base -n istio-system`
3. Install `Istio Discovery Chart`
  - `helm install istiod istio/istiod -n istio-system --wait`
4. Install an `Istio Ingress Gateway`
  - `kubectl create namespace istio-ingress`
  - `helm install istio-ingress istio/gateway -n istio-ingress --wait`