# https://spark.apache.org/
# https://www.youtube.com/watch?v=qnINvPqcRvE
# docker run -it --rm spark:r /opt/spark/bin/sparkR
install.packages("sparklyr")
library(sparklyr)
install.packages("pysparklyr")
library("pysparklyr")
library(devtools)
library(httr)
install_github("nagdevAmruthnath/minio.s3")
library("minio.s3")
library(aws.s3)
library(tidyverse)
library(dplyr)
library(readr)
library(DBI)

# Local Spark Cluster
# Installation
sparklyr::spark_install(version = "3.5.1")
spark_installed_versions()
spark_install_find(
  installed_only = TRUE
)

# Deinstallation Spark version 3.4.2
spark_uninstall("3.4.2", "3")
# Deinstallation Spark version 3.5.0
spark_uninstall("3.5.0", "3")

# Creation of local cluster
sc <- spark_connect(master = "local")
spark_web(sc)

# Connect to Databbricks (not possbile with Community Edition)
#sc <- spark_connect(
#  cluster_id = "community.cloud.databricks.com",
#  method = "databricks_connect"
#)

# Setting the environment variables
# https://localhost:9001/browser/templategenerator
set_config(config(ssl_verifyhost = 0L, ssl_verifypeer = 0L))
Sys.setenv("AWS_ACCESS_KEY_ID" = "health",
           "AWS_SECRET_ACCESS_KEY" = "NOentry#23",
           "AWS_SSL_ENABLED" = "TRUE",
           "AWS_S3_ENDPOINT" = "127.0.0.1:9000")

# Get file from the MinIO server
b <- get_bucket(bucket = 'templategenerator', region = "", use_https = TRUE)
iris <- aws.s3::s3read_using(FUN = read.csv, object = "iris.csv", bucket = b, opts = list(use_https = TRUE, region = ""))

# Spark dataframe
iris_tbl <- copy_to(sc, iris)

# Show dataframe
iris_tbl

# Use SQL on Spark
dbGetQuery(sc, "SELECT count(*) FROM iris")


## Spark connection to MinIO
## Version 1
# Establish Spark connection
sc <- spark_connect(master = "local")

# Getting spark context
ctx <- sparklyr::spark_context(sc)

# Using below to set the java spark context
jsc <- invoke_static(sc,
                     "org.apache.spark.api.java.JavaSparkContext",
                     "fromSparkContext",
                     ctx)

# Setting the s3 configs:
hconf <- jsc %>%
  invoke("hadoopConfiguration")

hconf %>%
  invoke("set", "fs.s3a.access.key", "health")

hconf %>%
  invoke("set", "fs.s3a.secret.key", "NOentry#23")

iris <- spark_read_csv(sc,
                       name = "iris",
                       path = "s3a://templategenerator/iris.csv")

## Version 2
# Set SSL configurations if necessary
set_config(config(ssl_verifyhost = 0L, ssl_verifypeer = 0L))

# Set AWS credentials and endpoint for MinIO
Sys.setenv(
  AWS_ACCESS_KEY_ID = "health",
  AWS_SECRET_ACCESS_KEY = "NOentry#23",
  AWS_SSL_ENABLED = "TRUE",
  AWS_S3_ENDPOINT = "127.0.0.1:9000")

# Define Spark configuration and include necessary Hadoop and AWS packages
config <- spark_config()
config$sparklyr.defaultPackages <- c(
  "org.apache.hadoop:hadoop-aws:3.4.1",
  "com.amazonaws:aws-java-sdk-bundle:1.12.778"
)

# Include additional Hadoop configurations for S3A
config[["spark.hadoop.fs.s3a.endpoint"]] <- "127.0.0.1:9000"
config[["spark.hadoop.fs.s3a.access.key"]] <- "health"
config[["spark.hadoop.fs.s3a.secret.key"]] <- "NOentry#23"
config[["spark.hadoop.fs.s3a.connection.ssl.enabled"]] <- "true"
config[["spark.hadoop.fs.s3a.path.style.access"]] <- "true"

# Establish Spark connection with the configuration
sc <- spark_connect(master = "local", config = config)

# Read the CSV file from MinIO
iris <- spark_read_csv(sc, path = "s3a://templategenerator/iris.csv")

# Display the schema of the loaded DataFrame
print(iris)

# Disconnect
spark_disconnect(sc)
