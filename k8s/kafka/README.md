#  注册Connector

## 新注册connector

```shell
curl -X POST http://34.91.208.145:8083/connectors -H "Content-Type: application/json" -d '{
  "name": "pgsql-connector",
  "config": {
    "retries": "10",
    "retry.backoff.ms": "10000",
    "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
    "database.hostname": "10.17.0.15",
    "database.port": "5432",
    "database.user": "cdc",
    "database.password": "cdc",
    "snapshot.mode": "initial",
    "database.dbname": "ebaymag_production",
    "database.server.name": "debezium.pgsql",
    "slot.name": "debezium_slot_v4",
    "plugin.name": "pgoutput",
    "topic.prefix": "debezium.pgsql",
    "schema.include.list": "public",
    "producer.override.max.request.size": "10485760",
    "producer.override.buffer.memory": "12485760",
    "topic.creation.default.replication.factor": "3",
    "topic.creation.default.partitions": "6",
    "offset.flush.interval.ms": "5000",
    "offset.storage.replication.factor": "3",
    "heartbeat.interval.ms": 1000,
    "snapshot.max.threads": 2,
    "event.processing.failure.handling.mode": "skip",
    "database.tcpKeepAlive": "true",
    "database.sslmode": "disable",
    "max.queue.size": "10000",
    "max.batch.size": "500",
    "task.max": "2",
    "snapshot.fetch.size": "1024",
    "poll.interval.ms": "50"
  }
}'
```


## 修改connector:
```shell
curl -X PUT http://34.91.208.145:8083/connectors/pgsql-connector/config -H "Content-Type: application/json" -d '{
    "retries": "10",
    "retry.backoff.ms": "10000",
    "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
    "database.hostname": "10.17.0.15",
    "database.port": "5432",
    "database.user": "cdc",
    "database.password": "cdc",
    "snapshot.mode": "initial",
    "database.dbname": "ebaymag_production",
    "database.server.name": "debezium.pgsql",
    "slot.name": "debezium_slot_v3",
    "plugin.name": "pgoutput",
    "topic.prefix": "debezium.pgsql",
    "schema.include.list": "public",
    "producer.override.max.request.size": "10485760",
    "producer.override.buffer.memory": "12485760",
    "topic.creation.default.replication.factor": "3",
    "topic.creation.default.partitions": "6",
    "offset.flush.interval.ms": "5000",
    "offset.storage.replication.factor": "3",
    "heartbeat.interval.ms": 1000,
    "snapshot.max.threads": 2,
    "event.processing.failure.handling.mode": "skip",
    "database.tcpKeepAlive": "true",
    "database.sslmode": "disable",
    "max.queue.size": "10000",
    "max.batch.size": "500",
    "task.max": "2",
    "snapshot.fetch.size": "1024",
    "poll.interval.ms": "50"
  }'
```

### 删除
```shell
curl -X DELETE http://34.91.252.48:8083/connectors/pgsql-connector
```

### 查看connector状态:
```shell
curl -X GET http://34.91.252.48:8083/connectors/pgsql-connector/status
```

### 查看connector配置
curl -X GET http://34.91.252.48:8083/connectors/pgsql-connector/config