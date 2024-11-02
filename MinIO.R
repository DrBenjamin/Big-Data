# MinIO R implementation
# https://blog.min.io/minio-apache-arrow-r/
library(devtools)
library(httr)
install_github("nagdevAmruthnath/minio.s3")
library("minio.s3")
library(aws.s3)
library(tidyverse)
library(dplyr)
library(readr)
library(png)
library(jpeg)

# Setting the environment variables
# https://localhost:9001/browser/templategenerator
set_config(config(ssl_verifypeer = 0L, ssl_verifyhost = 0L))
Sys.setenv("AWS_ACCESS_KEY_ID" = "health",
           "AWS_SECRET_ACCESS_KEY" = "NOentry#23",
           "AWS_SSL_ENABLED" = "TRUE",
           "AWS_S3_ENDPOINT" = "127.0.0.1:9000")

# Get files from the MinIO server
get_bucket(bucket = "templategenerator", region = "", use_https = TRUE)
b <- get_bucket(bucket = 'templategenerator', region = "", use_https = TRUE)
csv_file <- aws.s3::s3read_using(FUN = read.csv, object = "options.csv", bucket = b, opts = list(use_https = TRUE, region = ""))
head(csv_file)

image_file <- aws.s3::s3read_using(FUN = readJPEG, object = "Ben.jpg", bucket = b, opts = list(use_https = TRUE, region = ""))
grid::grid.raster(image_file)
