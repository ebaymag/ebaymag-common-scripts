-- 相关pod的重启
kubectl scale deployment scheduler  -n ebaymag --replicas=0
kubectl scale deployment scheduler  -n ebaymag --replicas=1
kubectl scale deployment sidekiq  -n ebaymag --replicas=0
kubectl scale deployment sidekiq  -n ebaymag --replicas=10
kubectl scale deployment sidekiq-important  -n ebaymag --replicas=0
kubectl scale deployment sidekiq-important  -n ebaymag --replicas=10
kubectl scale deployment ebay-webhooks -n ebaymag --replicas=0
kubectl scale deployment ebay-webhooks -n ebaymag --replicas=45
kubectl scale deployment asyncproxy -n ebaymag --replicas=0
kubectl scale deployment asyncproxy -n ebaymag --replicas=30
kubectl scale deployment sidekiq-jp -n ebaymag --replicas=0
kubectl scale deployment sidekiq-jp -n ebaymag --replicas=10
kubectl scale deployment sidekiq-others -n ebaymag --replicas=0
kubectl scale deployment sidekiq-others -n ebaymag --replicas=10
kubectl scale deployment sidekiq-internal  -n ebaymag --replicas=0
kubectl scale deployment sidekiq-internal  -n ebaymag --replicas=10
kubectl scale deployment sidekiq-internal-mapping  -n ebaymag --replicas=0
kubectl scale deployment sidekiq-internal-mapping  -n ebaymag --replicas=10
kubectl scale deployment web  -n ebaymag --replicas=0
kubectl scale deployment web  -n ebaymag --replicas=6
# 发布导入的 pod
kubectl scale deployment sidekiq  -n ebaymag --replicas=0
kubectl scale deployment sidekiq-important  -n ebaymag --replicas=0
kubectl scale deployment sidekiq-publish-jp  -n ebaymag --replicas=0
kubectl scale deployment sidekiq-publish-retry  -n ebaymag --replicas=0
kubectl scale deployment sidekiq-publish-his  -n ebaymag --replicas=0
kubectl scale deployment sidekiq-import  -n ebaymag --replicas=0
kubectl scale deployment sidekiq-auto-import  -n ebaymag --replicas=0
kubectl scale deployment sidekiq-internal  -n ebaymag --replicas=0
kubectl scale deployment sidekiq-internal-mapping  -n ebaymag --replicas=0
kubectl scale deployment sidekiq-jp  -n ebaymag --replicas=0
kubectl scale deployment sidekiq-others  -n ebaymag --replicas=0
kubectl scale deployment ebay-webhooks  -n ebaymag --replicas=0
kubectl scale deployment web  -n ebaymag --replicas=0


kubectl scale deployment sidekiq-publish-jp  -n ebaymag --replicas=10
kubectl scale deployment sidekiq-publish-retry  -n ebaymag --replicas=10
kubectl scale deployment sidekiq-publish-ecm  -n ebaymag --replicas=10
kubectl scale deployment sidekiq-publish-his  -n ebaymag --replicas=10
kubectl scale deployment sidekiq-import  -n ebaymag --replicas=10
kubectl scale deployment sidekiq-auto-import  -n ebaymag --replicas=10
kubectl scale deployment sidekiq-jp  -n ebaymag --replicas=10
kubectl scale deployment sidekiq-others  -n ebaymag --replicas=10
kubectl scale deployment ebay-webhooks  -n ebaymag --replicas=40
kubectl scale deployment web  -n ebaymag --replicas=10
kubectl scale deployment sidekiq-internal  -n ebaymag --replicas=1
kubectl scale deployment sidekiq-internal-mapping  -n ebaymag --replicas=5
kubectl scale deployment sidekiq  -n ebaymag --replicas=30
kubectl scale deployment sidekiq-important  -n ebaymag --replicas=30


#grafana
kubectl scale deployment prometheus-prometheus-operator-kube-p-prometheus-0 -n monitoring --context=gke_ebay-mag_europe-west4-b_production --replicas=0

kubectl delete pod prometheus-prometheus-operator-kube-p-prometheus-0 -n monitoring

#获取 poddisruptionbudgets，如果在部署时遇到
kubectl get poddisruptionbudgets -n alpha


kubectl get pods --field-selector=status.phase!=Running -n ebaymag

kubectl delete pods --field-selector=status.phase!=Running -n ebaymag

kubectl get pods -n ebaymag | grep CrashLoopBackOff | awk '{print $1}' | xargs kubectl delete pod -n ebaymag


