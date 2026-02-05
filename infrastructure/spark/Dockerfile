# =============================================================================
# Dockerfile para Apache Spark
# Big Data UAG 2026 - AWS Academy Data Engineering
# =============================================================================

FROM spark:3.5.0-scala2.12-java17-python3-ubuntu

# Metadata
LABEL maintainer="Big Data UAG 2026"
LABEL description="Apache Spark 3.5.0 con soporte para Delta Lake y conectores"

USER root

# Instalar dependencias del sistema y Python 3.11 (para coincidir con Jupyter)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    wget \
    procps \
    software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa -y \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    python3.11 \
    python3.11-venv \
    python3.11-distutils \
    && rm -rf /var/lib/apt/lists/* \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 \
    && update-alternatives --set python3 /usr/bin/python3.11

# Crear directorios de trabajo
RUN mkdir -p /data /labs /src && \
    chmod -R 777 /data /labs /src

# Descargar JARs necesarios para Delta Lake y conectores
WORKDIR /opt/spark/jars

# Delta Lake
RUN wget -q https://repo1.maven.org/maven2/io/delta/delta-spark_2.12/3.1.0/delta-spark_2.12-3.1.0.jar && \
    wget -q https://repo1.maven.org/maven2/io/delta/delta-storage/3.1.0/delta-storage-3.1.0.jar

# Kafka connector
RUN wget -q https://repo1.maven.org/maven2/org/apache/spark/spark-sql-kafka-0-10_2.12/3.5.0/spark-sql-kafka-0-10_2.12-3.5.0.jar && \
    wget -q https://repo1.maven.org/maven2/org/apache/kafka/kafka-clients/3.5.0/kafka-clients-3.5.0.jar && \
    wget -q https://repo1.maven.org/maven2/org/apache/spark/spark-token-provider-kafka-0-10_2.12/3.5.0/spark-token-provider-kafka-0-10_2.12-3.5.0.jar && \
    wget -q https://repo1.maven.org/maven2/org/apache/commons/commons-pool2/2.11.1/commons-pool2-2.11.1.jar

# PostgreSQL JDBC
RUN wget -q https://repo1.maven.org/maven2/org/postgresql/postgresql/42.6.0/postgresql-42.6.0.jar

# AWS S3 (para MinIO)
RUN wget -q https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.4/hadoop-aws-3.3.4.jar && \
    wget -q https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.262/aws-java-sdk-bundle-1.12.262.jar

WORKDIR /opt/spark

# Variables de entorno
ENV SPARK_HOME=/opt/spark
ENV PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin
ENV SPARK_NO_DAEMONIZE=true
ENV PYSPARK_PYTHON=python3.11
ENV PYSPARK_DRIVER_PYTHON=python3.11
