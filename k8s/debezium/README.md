# Deploy CDC streaming pipeline

## 1.Prerequisites
### 1.1 Database updates
For GCP Cloud SQL pgsql, we need to first eanble the logical decoding configuration, this operation will need a restart to activate the changes.
```properties
cloudsql.logical_decoding=true
```

### 1.2 Add a replication user
```sql
ALTER USER cdc WITH replication;
```

## 2. Deploy Debezium service to GKE
### 2.1 Create a namespace
```bash
kubectl create namespace debezium
```

### 2.2 Deploy Debezium
```bash
helm install debezium k8s/debezium -n debezium
```

upgrade the deployment
```bash
helm upgrade debezium k8s/debezium -n debezium
```

