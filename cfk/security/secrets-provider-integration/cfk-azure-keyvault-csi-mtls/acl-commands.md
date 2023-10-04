# For Schema Registry

```
/bin/kafka-acls --bootstrap-server kafka.confluent.svc.cluster.local:9071 \
 --command-config /opt/confluentinc/admin.properties \
 --add \
 --allow-principal "User:sr" \
 --operation Read --operation Write --operation Create \
 --topic _confluent-license

/bin/kafka-acls --bootstrap-server kafka.confluent.svc.cluster.local:9071 \
 --command-config /opt/confluentinc/admin.properties \
 --add \
 --allow-principal "User:sr" \
 --operation Describe \
 --topic __consumer_offsets \
 --topic _confluent-metrics \
 --topic _confluent-telemetry-metrics \
 --topic _confluent-command \
 --topic _confluent-monitoring \
 --topic confluent.connect-configs \
 --topic confluent.connect-offsets \
 --topic confluent.connect-statuses \
 --topic _confluent-ksql-confluent.ksqldb__command_topic
 
/bin/kafka-acls --bootstrap-server kafka.confluent.svc.cluster.local:9071 \
 --command-config /opt/confluentinc/admin.properties \
 --add \
 --allow-principal "User:sr" \
 --operation Describe \
 --topic _confluent_balancer \
 --topic _confluent-controlcenter \
 --resource-pattern-type prefixed

##### The schemas topic is named: _schemas_<sr-cluster-name>_<namespace>
/bin/kafka-acls --bootstrap-server kafka.confluent.svc.cluster.local:9071 \
 --command-config /opt/confluentinc/admin.properties \
 --add \
 --allow-principal "User:sr" \
 --operation Read --operation Write --operation Create --operation DescribeConfigs --operation Describe \
 --topic _schemas_demo

##### The Schema Registry consumer group is: id_<sr-cluster-name>_<namespace>
/bin/kafka-acls --bootstrap-server kafka.confluent.svc.cluster.local:9071 \
 --command-config /opt/confluentinc/admin.properties \
 --add \
 --allow-principal "User:sr" \
 --operation Read \
 --group schema-registry-demo

/bin/kafka-acls --bootstrap-server kafka.confluent.svc.cluster.local:9071 \
 --command-config /opt/confluentinc/admin.properties \
 --add \
 --allow-principal "User:sr" \
 --operation ClusterAction \
 --cluster kafka-cluster
```




# For Connect

```
##### The Connect topic prefix is: <namespace>.<connect-cluster-name>-
/bin/kafka-acls --bootstrap-server kafka.confluent.svc.cluster.local:9071 \
 --command-config /opt/confluentinc/admin.properties \
 --add \
 --allow-principal "User:connect" \
 --operation Read --operation Write --operation Create \
 --topic demo-connect- \
 --resource-pattern-type prefixed

/bin/kafka-acls --bootstrap-server kafka.confluent.svc.cluster.local:9071 \
 --command-config /opt/confluentinc/admin.properties \
 --add \
 --allow-principal "User:connect" \
 --operation Write \
 --topic _confluent-monitoring \
 --resource-pattern-type prefixed

##### The Connect consumer group is: <namespace>.<connect-cluster-name>
/bin/kafka-acls --bootstrap-server kafka.confluent.svc.cluster.local:9071 \
 --command-config /opt/confluentinc/admin.properties \
 --add \
 --allow-principal "User:connect" \
 --operation Read \
 --group demo-connect-cluster

/bin/kafka-acls --bootstrap-server kafka.confluent.svc.cluster.local:9071 \
 --command-config /opt/confluentinc/admin.properties \
 --add \
 --allow-principal "User:connect" \
 --operation Create --operation ClusterAction \
 --cluster kafka-cluster

/bin/kafka-acls --bootstrap-server kafka.confluent.svc.cluster.local:9071 \
 --command-config /opt/confluentinc/admin.properties \
 --add \
 --allow-principal "User:connect" \
 --operation Describe \
 --topic _confluent-controlcenter \
 --resource-pattern-type prefixed

 /bin/kafka-acls --bootstrap-server kafka.confluent.svc.cluster.local:9071 \
 --command-config /opt/confluentinc/admin.properties \
 --add \
 --allow-principal "User:connect" \
 --operation Describe \
 --topic __consumer_offsets \
 --topic _confluent-command \
 --topic _confluent-ksql-confluent.ksqldb__command_topic \
 --topic _confluent-license \
 --topic _confluent-metrics \
 --topic _confluent-telemetry-metrics \
 --topic _confluent_balancer_api_state \
 --topic _confluent_balancer_broker_samples \
 --topic _confluent_balancer_partition_samples \
 --topic _schemas_demo \
 --topic demo-connect-offsets
```


# For ksqlDB

```
/bin/kafka-acls --bootstrap-server kafka.confluent.svc.cluster.local:9071 \
 --command-config /opt/confluentinc/admin.properties \
 --add \
 --allow-principal "User:ksql" \
 --operation Read --operation Write --operation Create \
 --topic demo-ksqldb_\
 --resource-pattern-type prefixed

/bin/kafka-acls --bootstrap-server kafka.confluent.svc.cluster.local:9071 \
 --command-config /opt/confluentinc/admin.properties \
 --add \
 --allow-principal "User:ksql" \
 --operation All \
 --topic _confluent-ksql-demo-ksqldb \
 --resource-pattern-type prefixed

 /bin/kafka-acls --bootstrap-server kafka.confluent.svc.cluster.local:9071 \
 --command-config /opt/confluentinc/admin.properties \
 --add \
 --allow-principal "User:ksql" \
 --operation Describe \
 --cluster kafka-cluster
```



# For Control Center

```
/bin/kafka-acls --bootstrap-server kafka.confluent.svc.cluster.local:9071 \
 --command-config /opt/confluentinc/admin.properties \
 --add \
 --allow-principal "User:c3" \
 --operation Read --operation Write --operation Create --operation Alter --operation AlterConfigs --operation Delete \
 --topic _confluent-controlcenter \
 --resource-pattern-type prefixed

/bin/kafka-acls --bootstrap-server kafka.confluent.svc.cluster.local:9071 \
 --command-config /opt/confluentinc/admin.properties \
 --add \
 --allow-principal "User:c3" \
 --operation Read --operation Write --operation Create \
 --topic _confluent-command

/bin/kafka-acls --bootstrap-server kafka.confluent.svc.cluster.local:9071 \
 --command-config /opt/confluentinc/admin.properties \
 --add \
 --allow-principal "User:c3" \
 --operation Read --operation Write --operation Create --operation DescribeConfigs --operation Describe \
 --topic _confluent-metrics

/bin/kafka-acls --bootstrap-server kafka.confluent.svc.cluster.local:9071 \
 --command-config /opt/confluentinc/admin.properties \
 --add \
 --allow-principal "User:c3" \
 --operation Read --operation Write --operation Create --operation DescribeConfigs --operation Describe --operation Alter --operation AlterConfigs --operation Delete \
 --topic _confluent-monitoring \
 --topic _confluent-telemetry-metrics \
 --topic demo-connect-configs \
 --topic demo-connect-offsets \
 --topic demo-connect-statuses \
  --topic __consumer_offsets

/bin/kafka-acls --bootstrap-server kafka.confluent.svc.cluster.local:9071 \
 --command-config /opt/confluentinc/admin.properties \
 --add \
 --allow-principal "User:c3" \
 --operation Describe --operation Alter --operation AlterConfigs --operation Create --operation Delete --operation DescribeConfigs \
 --topic _confluent_balancer_api_state \
 --topic _confluent_balancer_broker_samples \
 --topic _confluent_balancer_partition_samples \
 --topic _confluent-command \
 --topic _confluent-ksql-demo-ksqldb__command_topic \
 --topic _confluent-license \
 --topic _confluent-telemetry-metrics \
 --topic _schemas_demo

/bin/kafka-acls --bootstrap-server kafka.confluent.svc.cluster.local:9071 \
 --command-config /opt/confluentinc/admin.properties \
 --add \
 --allow-principal "User:c3" \
 --operation DescribeConfigs \
 --topic _confluent-command

/bin/kafka-acls --bootstrap-server kafka.confluent.svc.cluster.local:9071 \
 --command-config /opt/confluentinc/admin.properties \
 --add \
 --allow-principal "User:c3" \
 --operation DescribeConfigs \
 --topic _confluent-controlcenter \
 --resource-pattern-type prefixed

/bin/kafka-acls --bootstrap-server kafka.confluent.svc.cluster.local:9071 \
 --command-config /opt/confluentinc/admin.properties \
 --add \
 --allow-principal "User:c3" \
 --operation AlterConfigs --operation Create --operation Describe --operation DescribeConfigs --operation Describe --operation ClusterAction \
 --cluster kafka-cluster

/bin/kafka-acls --bootstrap-server kafka.confluent.svc.cluster.local:9071 \
 --command-config /opt/confluentinc/admin.properties \
 --add \
 --allow-principal "User:c3" \
 --operation AlterConfigs --operation Create --operation Describe --operation DescribeConfigs --operation Create \
 --cluster kafka-cluster

/bin/kafka-acls --bootstrap-server kafka.confluent.svc.cluster.local:9071 \
 --command-config /opt/confluentinc/admin.properties \
 --add \
 --allow-principal "User:c3" \
 --operation Describe --operation Delete --operation Read \
 --group ConfluentTelemetryReporterSampler \
 --resource-pattern-type prefixed

/bin/kafka-acls --bootstrap-server kafka.confluent.svc.cluster.local:9071 \
 --command-config /opt/confluentinc/admin.properties \
 --add \
 --allow-principal "User:c3" \
 --operation All \
 --group _confluent-controlcenter \
 --resource-pattern-type prefixed
```
