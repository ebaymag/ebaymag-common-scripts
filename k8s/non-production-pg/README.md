# Helm chart to deploy pgbouncer and pgsql in Pods

> This chart is only used for non-production env to deploy database and connection pool. Because for production env, we are using the GCP built-in cloud sql.
>
> This chart will finally deploy two workloads:
> - pgsql database
> - pgbouncer connection pool

## 1. First time deploy a helm chart
- <release-name>: your customized helm release name. For example, if the release-name=asyncproxy, then the workload would be `asyncproxy-postgresql`
- <non-production-namespace>: k8s namespace
```shell
helm install <release-name> ./ -n <namespace>
```

## 2. Upgrade helm
```shell
helm get values <release-name> -n <namespace>  ./tmp_helm_value.yaml

helm upgrade <release-name> ./ -n <namespace> -f ./tmp_helm_value.yaml
```

