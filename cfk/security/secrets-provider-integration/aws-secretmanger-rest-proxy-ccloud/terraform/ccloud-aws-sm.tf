resource "aws_secretsmanager_secret" "restproxy_clients" {
 name = "cfk/restproxy/rest-basic.txt"
 description = "test tf secret"
}

resource "aws_secretsmanager_secret_version" "service_user" {
 secret_id   = aws_secretsmanager_secret.restproxy_clients.id
 secret_string = "${confluent_api_key.krp-api-key-1.id}: ${confluent_api_key.krp-api-key-1.secret},krp-users"
}

resource "aws_secretsmanager_secret" "restproxy_jaas" {
 name = "cfk/restproxy/rest-ccloud-jaas-api-access.conf"
 description = "test tf jaas secret"
}

resource "aws_secretsmanager_secret_version" "rp_jaas_user" {
 secret_id   = aws_secretsmanager_secret.restproxy_jaas.id
 secret_string = "KafkaRest {\n org.eclipse.jetty.jaas.spi.PropertyFileLoginModule required \n debug=true \n file=/mnt/secrets/cp2ccloud-rest-users/basic.txt; \n};\n\nKafkaClient {\n org.apache.kafka.common.security.plain.PlainLoginModule required \n username=${confluent_api_key.krp-api-key-1.id} \n password=${confluent_api_key.krp-api-key-1.secret}; \n};\n"