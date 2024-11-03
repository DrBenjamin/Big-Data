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
sparklyr::spark_install(version = "3.5.0")
spark_installed_versions()
sc <- spark_connect(master = "local")
spark_web(sc)
# Connect to Databbricks (not possbile with Community Edition)
sc <- spark_connect(
  cluster_id = "community.cloud.databricks.com",
  method = "databricks_connect"
)

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

# Disconnect
spark_disconnect(sc)
