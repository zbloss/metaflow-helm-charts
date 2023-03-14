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

| Link     | Description |
|----------|-------------|
| [Kubegres](https://www.kubegres.io/) | Kubernetes Operator that provides highly-available deployments of Postgresql |
| | |

#### Kubegres

Kubegress provides a kubernetes operator that allows for highly-available and highly-scalable PostgreSQL deployments on kubernetes. Often folks avoid putting databases on kubernetes because you need to manage things like backups, primary/secondary failover(s), etc. Reaching for AWS RDS is usually simpler, but Kubegress now provides a CRD `kind: Kubegres` that handles a lot of these problems out of the box.

```bash

# Pending a PR Merge from the Kubegres Team: 
# https://github.com/reactive-tech/kubegres/pull/153
# export KUBEGRES_VERSION=1.16
# kubectl apply -f https://raw.githubusercontent.com/reactive-tech/kubegres/v$(echo $KUBEGRES_VERSION)/kubegres.yaml

kubectl apply -f https://raw.githubusercontent.com/zbloss/kubegres/main/kubegres.yaml

```
