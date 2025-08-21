echo '开始删除文件'
kubectl exec  -it prometheus-prometheus-operator-kube-p-prometheus-0 --context=gke_ebay-mag_europe-west4-b_production -n monitoring -- /bin/sh -c "cd /prometheus/wal && echo '进入wal file' && echo '开始删除文件' && rm -rf ./* && echo '删除成功'"
