# metaflow-helm-charts

Home for deploying Metaflow on kubernetes as easy as possible.

These charts are aimed first at teams who want to get a development Metaflow stack running as fast as possible. This project provides charts for the following:

* [Metaflow UI](https://github.com/Netflix/metaflow-ui)
* [Metaflow Service](https://github.com/Netflix/metaflow-service)
* [Metaflow itself](https://github.com/Netflix/metaflow)

It also integrates with a few other cool projects to improve the developer experience:

* [Kubegres](https://github.com/reactive-tech/kubegres)
* [Minio](https://github.com/minio/minio)

Once the goal of delivering a kubernetes-native Metaflow deployment is mature, we will begin rolling additional features to this chart that will allow integrations directly with infrastructure on AWS, Azure, and GCP so that you can use the same helm chart regardless of where your infrastructure lives.

## Getting Started