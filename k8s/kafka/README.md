#  注册Connector

## 新注册connector

```shell
curl -X POST http://34.34.96.52:8083 /connectors -H "Content-Type: application/json" -d '{
  "name": "pgsql-connector",
  "config": {
    "retries": "100000",
    "retry.backoff.ms": "10000",
    "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
    "database.hostname": "10.17.0.15",
    "database.port": "5432",
    "database.user": "cdc",
    "database.password": "cdc",
    "snapshot.mode": "never",
    "database.dbname": "ebaymag_production",
    "database.server.name": "debezium.pgsql",
    "slot.name": "debezium_slot_v1",
    "plugin.name": "pgoutput",
    "tasks.max": "10",
    "topic.prefix": "debezium.pgsql",
    "schema.include.list": "public",
    "producer.override.max.request.size": "10485760",
    "producer.override.buffer.memory": "12485760",
    "topic.creation.default.replication.factor": "3",
    "topic.creation.default.partitions": "6"
  }
}'
```

```shell
curl -X POST http://34.34.96.52:8083/connectors -H "Content-Type: application/json" -d '{
  "name": "pgsql-connector-listings",
  "config": {
    "retries": "100000",
    "retry.backoff.ms": "10000",
    "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
    "database.hostname": "10.17.0.15",
    "database.port": "5432",
    "database.user": "cdc",
    "database.password": "cdc",
    "snapshot.mode": "never",
    "database.dbname": "ebaymag_production",
    "database.server.name": "debezium.pgsql",
    "slot.name": "debezium_slot_listing",
    "plugin.name": "pgoutput",
    "tasks.max": "10",
    "topic.prefix": "debezium.pgsql",
    "table.include.list": "public.listings,public.listing_variations,public.problems",
    "producer.override.max.request.size": "10485760",
    "producer.override.buffer.memory": "12485760",
    "topic.creation.default.replication.factor": "3",
    "topic.creation.default.partitions": "6"
  }
}'

curl -X POST http://34.34.96.52:8083/connectors -H "Content-Type: application/json" -d '{
  "name": "pgsql-connector-products",
  "config": {
    "retries": "100000",
    "retry.backoff.ms": "10000",
    "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
    "database.hostname": "10.17.0.15",
    "database.port": "5432",
    "database.user": "cdc",
    "database.password": "cdc",
    "snapshot.mode": "never",
    "database.dbname": "ebaymag_production",
    "database.server.name": "debezium.pgsql",
    "slot.name": "debezium_slot_products",
    "plugin.name": "pgoutput",
    "tasks.max": "10",
    "topic.prefix": "debezium.pgsql",
    "table.include.list": "public.products,public.showcases,public.ssku_product_variations,public.product_attributes,public.product_descriptions,public.product_import_items,public.product_import_tasks,public.product_sync_tasks,public.product_variations",
    "producer.override.max.request.size": "10485760",
    "producer.override.buffer.memory": "12485760",
    "topic.creation.default.replication.factor": "3",
    "topic.creation.default.partitions": "6"
  }
}'
```


## 修改connector:
```shell
curl -X PUT http://34.34.96.52:8083/connectors/pgsql-connector/config -H "Content-Type: application/json" -d '{
    "retries": "100000",
    "retry.backoff.ms": "10000",
    "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
    "database.hostname": "10.17.0.15",
    "database.port": "5432",
    "database.user": "cdc",
    "database.password": "cdc",
    "snapshot.mode": "never",
    "database.dbname": "ebaymag_production",
    "database.server.name": "debezium.pgsql",
    "slot.name": "debezium_slot_v1",
    "plugin.name": "pgoutput",
    "tasks.max": "10",
    "topic.prefix": "debezium.pgsql",
    "schema.include.list": "public",
    "producer.override.max.request.size": "10485760",
    "producer.override.buffer.memory": "12485760",
    "topic.creation.default.replication.factor": "3",
    "topic.creation.default.partitions": "6"
  }'
```

### 删除
```shell
curl -X DELETE http://34.34.96.52:8083/connectors/pgsql-connector
```

### 查看connector状态:
```shell
curl -X GET http://34.34.96.52:8083/connectors/pgsql-connector/status
```

### 查看connector配置
curl -X GET http://34.34.96.52:8083/connectors/pgsql-connector/config