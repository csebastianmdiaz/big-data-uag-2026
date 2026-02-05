# =============================================================================
# Dockerfile para Jupyter Lab con PySpark
# Big Data UAG 2026 - AWS Academy Data Engineering
# =============================================================================

FROM jupyter/pyspark-notebook:spark-3.5.0

# Metadata
LABEL maintainer="Big Data UAG 2026"
LABEL description="Jupyter Lab con PySpark 3.5 y librerias de Data Science"

USER root

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    wget \
    graphviz \
    && rm -rf /var/lib/apt/lists/*

# Crear directorios de trabajo
RUN mkdir -p /home/jovyan/data /home/jovyan/labs /home/jovyan/src && \
    chown -R jovyan:users /home/jovyan

USER jovyan

# Copiar requirements e instalar dependencias Python
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# Descargar JARs para Spark (Delta Lake, Kafka, etc.)
USER root
WORKDIR /usr/local/spark/jars

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

USER jovyan

WORKDIR /home/jovyan

# Configurar variables de entorno para Spark (Python 3.11 para coincidir con workers)
ENV PYSPARK_PYTHON=python3.11
ENV PYSPARK_DRIVER_PYTHON=python3.11
ENV SPARK_HOME=/usr/local/spark
ENV PATH=$PATH:$SPARK_HOME/bin

# Puerto de Jupyter Lab
EXPOSE 8888
# Puerto de Spark UI
EXPOSE 4040
