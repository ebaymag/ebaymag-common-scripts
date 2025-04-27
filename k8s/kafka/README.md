#  注册Connector

## 新注册connector

```shell
curl -X POST http://localhost:8083/connectors -H "Content-Type: application/json" -d '{
  "name": "pgsql-connector",
  "config": {
    "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
    "database.hostname": "10.17.0.15",
    "database.port": "5432",
    "database.user": "cdc",
    "database.password": "cdc",
    "snapshot.mode": "never",
    "database.dbname": "ebaymag_production",
    "database.server.name": "debezium.pgsql",
    "slot.name": "debezium_slot",
    "plugin.name": "pgoutput",
    "tasks.max": "10",
    "topic.prefix": "debezium.pgsql",
    "schema.include.list": "public",
    "producer.override.max.request.size": "10485760",
    "producer.override.buffer.memory": "12485760"
  }
}'
```

## 修改connector:
```shell
curl -X PUT http://localhost:9090/connectors/pgsql-connector/config -H "Content-Type: application/json" -d '{
  "name": "pgsql-connector",
  "config": {
    "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
    "database.hostname": "10.17.0.15",
    "database.port": "5432",
    "database.user": "cdc",
    "database.password": "cdc",
    "snapshot.mode": "never",
    "database.dbname": "ebaymag_production",
    "database.server.name": "debezium.pgsql",
    "slot.name": "debezium_slot",
    "plugin.name": "pgoutput",
    "tasks.max": "20",
    "topic.prefix": "debezium.pgsql",
    "schema.include.list": "public",
    "producer.override.max.request.size": "10485760",
    "producer.buffer.memory": "12485760"
  }
}'
```

### 删除
```shell
curl -X DELETE http://localhost:8083/connectors/pgsql-connector
```

### 查看connector状态:
```shell
curl -X GET http://localhost:9090/connectors/pgsql-connector/status
```

### 查看connector配置
curl -X GET http://localhost:8083/connectors/pgsql-connector/config