### Prep Certs in assets folder


      // Create component certs
      cd into 
      export TUTORIAL_HOME=<Git repository path>/assets/certs/component-certs
      export TUTORIAL_HOME=$PWD

### create a certifciate autority
Certificate authority (CA) private key (ca-key.pem/rootCAkey.pem)
Certificate authority (CA) certificate (ca.pem / cacerts.pem)


    mkdir $TUTORIAL_HOME/generated && openssl genrsa -out $TUTORIAL_HOME/generated/rootCAkey.pem 2048

    openssl req -x509  -new -nodes \
      -key $TUTORIAL_HOME/generated/rootCAkey.pem \
      -days 3650 \
      -out $TUTORIAL_HOME/generated/cacerts.pem \
      -subj "/C=US/ST=CA/L=MVT/O=TestOrg/OU=Cloud/CN=TestCA"

      #check validity
      openssl x509 -in $TUTORIAL_HOME/generated/cacerts.pem -text -noout
    
### create CFLT server certificate

    # Create Conjur server certificates
    # Use the SANs listed in conjur-server-domain.json

    cfssl gencert -ca=$TUTORIAL_HOME/generated/cacerts.pem \
    -ca-key=$TUTORIAL_HOME/generated/rootCAkey.pem \
    -config=$TUTORIAL_HOME/ca-config.json \
    -profile=server $TUTORIAL_HOME/conjur-server-domain.json | cfssljson -bare $TUTORIAL_HOME/generated/conjur-server


    # Create Zookeeper server certificates
    # Use the SANs listed in zookeeper-server-domain.json

    cfssl gencert -ca=$TUTORIAL_HOME/generated/cacerts.pem \
    -ca-key=$TUTORIAL_HOME/generated/rootCAkey.pem \
    -config=$TUTORIAL_HOME/ca-config.json \
    -profile=server $TUTORIAL_HOME/zookeeper-server-domain.json | cfssljson -bare $TUTORIAL_HOME/generated/zookeeper-server

    # Create Kafka server certificates
    # Use the SANs listed in kafka-server-domain.json

    cfssl gencert -ca=$TUTORIAL_HOME/generated/cacerts.pem \
    -ca-key=$TUTORIAL_HOME/generated/rootCAkey.pem \
    -config=$TUTORIAL_HOME/ca-config.json \
    -profile=server $TUTORIAL_HOME/kafka-server-domain.json | cfssljson -bare $TUTORIAL_HOME/generated/kafka-server

    # Create ControlCenter server certificates
    # Use the SANs listed in controlcenter-server-domain.json

    cfssl gencert -ca=$TUTORIAL_HOME/generated/cacerts.pem \
    -ca-key=$TUTORIAL_HOME/generated/rootCAkey.pem \
    -config=$TUTORIAL_HOME/ca-config.json \
    -profile=server $TUTORIAL_HOME/controlcenter-server-domain.json | cfssljson -bare $TUTORIAL_HOME/generated/controlcenter-server

    # Create SchemaRegistry server certificates
    # Use the SANs listed in schemaregistry-server-domain.json

    cfssl gencert -ca=$TUTORIAL_HOME/generated/cacerts.pem \
    -ca-key=$TUTORIAL_HOME/generated/rootCAkey.pem \
    -config=$TUTORIAL_HOME/ca-config.json \
    -profile=server $TUTORIAL_HOME/schemaregistry-server-domain.json | cfssljson -bare $TUTORIAL_HOME/generated/schemaregistry-server

    # Create Connect server certificates
    # Use the SANs listed in connect-server-domain.json

    cfssl gencert -ca=$TUTORIAL_HOME/generated/cacerts.pem \
    -ca-key=$TUTORIAL_HOME/generated/rootCAkey.pem \
    -config=$TUTORIAL_HOME/ca-config.json \
    -profile=server $TUTORIAL_HOME/connect-server-domain.json | cfssljson -bare $TUTORIAL_HOME/generated/connect-server

    # Create ksqlDB server certificates
    # Use the SANs listed in ksqldb-server-domain.json

    cfssl gencert -ca=$TUTORIAL_HOME/generated/cacerts.pem \
    -ca-key=$TUTORIAL_HOME/generated/rootCAkey.pem \
    -config=$TUTORIAL_HOME/ca-config.json \
    -profile=server $TUTORIAL_HOME/ksqldb-server-domain.json | cfssljson -bare $TUTORIAL_HOME/generated/ksqldb-server

    # Create Kafka Rest Proxy server certificates
    # Use the SANs listed in kafkarestproxy-server-domain.json

    cfssl gencert -ca=$TUTORIAL_HOME/generated/cacerts.pem \
    -ca-key=$TUTORIAL_HOME/generated/rootCAkey.pem \
    -config=$TUTORIAL_HOME/ca-config.json \
    -profile=server $TUTORIAL_HOME/kafkarestproxy-server-domain.json | cfssljson -bare $TUTORIAL_HOME/generated/kafkarestproxy-server



### Validity of server certifiates
    openssl x509 -in $TUTORIAL_HOME/generated/conjur-server.pem -text -noout

    openssl x509 -in $TUTORIAL_HOME/generated/zookeeper-server.pem -text -noout

    openssl x509 -in $TUTORIAL_HOME/generated/kafka-server.pem -text -noout

    openssl x509 -in $TUTORIAL_HOME/generated/controlcenter-server.pem -text -noout

    openssl x509 -in $TUTORIAL_HOME/generated/schemaregistry-server.pem -text -noout

    openssl x509 -in $TUTORIAL_HOME/generated/connect-server.pem -text -noout

    openssl x509 -in $TUTORIAL_HOME/generated/ksqldb-server.pem -text -noout

    openssl x509 -in $TUTORIAL_HOME/generated/kafkarestproxy-server.pem -text -noout


-----------------------------------------------