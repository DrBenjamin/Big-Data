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
install.packages("aws.s3", repos = c("cloudyr" = "http://cloudyr.github.io/drat"))
library(aws.s3)
install.packages("tidyverse")
library(tidyverse)
library(dplyr)
library(readr)
library(DBI)
library(knitr)
library(fs)

# Local Spark Cluster
# Installation
sparklyr::spark_install(version = "3.5.1")
spark_installed_versions()
spark_install_find(
  installed_only = TRUE
)
spark_available_versions()
spark_available_versions(show_minor = TRUE)

# Deinstallation Spark version 2.4.8
spark_uninstall("2.4.8", "2.7")
# Deinstallation Spark version 3.0.3
spark_uninstall("3.0.3", "3.2")
# Deinstallation Spark version 3.4.2
spark_uninstall("3.4.1", "3")
# Deinstallation Spark version 3.5.1
spark_uninstall("3.5.0", "3")

# Creation of local cluster
sc <- spark_connect(master = "local", version = "3.5.1")
spark_web(sc)

# Connect to Databbricks (not possbile with Community Edition)
#sc <- spark_connect(
#  cluster_id = "community.cloud.databricks.com",
#  method = "databricks_connect"
#)

# Setting the environment variables
# https://localhost:9001/browser/templategenerator
set_config(config(ssl_verifyhost = 0L, ssl_verifypeer = 0L))

# Get environment variables
Sys.getenv("JAVA_HOME")

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
# Set SSL configurations if necessary
#set_config(config(ssl_verifyhost = 0L, ssl_verifypeer = 0L))

# Set AWS credentials and endpoint for MinIO
Sys.setenv(
           AWS_ACCESS_KEY = "health",
           AWS_SECRET_KEY = "NOentry#23",
           AWS_SSL_ENABLED = "FALSE",
           AWS_S3_ENDPOINT = "127.0.0.1:9000")

# Define Spark configuration and include necessary Hadoop and AWS packages
config <- spark_config()
config$sparklyr.defaultPackages <- c(
  "org.apache.hadoop:hadoop-aws:3.3.1",
  "com.amazonaws:aws-java-sdk-core:1.12.150"
)

# Include additional Hadoop configurations for S3A
config[["spark.hadoop.fs.s3a.endpoint"]] <- "127.0.0.1:9000"
config[["spark.hadoop.fs.s3a.access.key"]] <- "health"
config[["spark.hadoop.fs.s3a.secret.key"]] <- "NOentry#23"
config[["spark.hadoop.fs.s3a.connection.ssl.enabled"]] <- "false"
config[["spark.hadoop.fs.s3a.path.style.access"]] <- "true"
config[["spark.hadoop.fs.s3a.aws.credentials.provider"]] <- "org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider"

# Establish Spark connection with the configuration
sc <- spark_connect(master = "local", version = "3.2.1", config = config)

# Read the CSV file from MinIO
iris <- spark_read_csv(sc, path = "s3a://templategenerator/iris.csv")
print(iris)

# Reading a CSV file from MinIO
options <- spark_read_csv(sc, path = "s3a://templategenerator/options.csv")
print(options)

# Reading a CSV file from MinIO
presets <- spark_read_csv(sc, path = "s3a://templategenerator/presets.csv")
print(presets)

# Creating a test data frame from csv file
test_df <- read.csv("test.csv", header = TRUE)
kable(test_df)

# Copy the data frame to Spark
test_spark_df <- copy_to(sc, test_df, overwrite = TRUE)

# Write the Spark DataFrame to MinIO
spark_write_csv(test_spark_df,
                name = "test2",
                memory = TRUE,
                path = "s3a://templategenerator/test2",
                mode = "overwrite")

# Load the table into Spark memory
tbl_cache(sc, "test_df")
cached_df <- tbl(sc, "test_df")

# Run SQL queries
result <- dbGetQuery(sc, "SELECT * FROM test_df LIMIT 5")
print(result)

# Remove variable `cached_df` from global environment
rm(cached_df)

# Disconnect
spark_disconnect(sc)
