# Import the SparkSession module
from pyspark.sql import SparkSession
import streamlit as st
import pandas as pd
import sys
import os
import io
import urllib3
from minio import Minio

# Streamlit Title
st.title("Streamlit with PySpark")

# Show Python Version
st.write(sys.version)

# Create a SparkSession
spark = SparkSession.builder.appName("SparkApp").master("local").config("spark.hadoop.fs.s3a.aws.credentials.provider", "org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider").getOrCreate()
st.success("SparkSession created successfully")

# Get the SparkContext from the SparkSession
sc = spark.sparkContext
st.success("SparkContext retreived successfully")

# Disable SSL verification warnings
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# Setting the environment variables
os.environ["AWS_ACCESS_KEY_ID"] = "health"
os.environ["AWS_SECRET_ACCESS_KEY"] = "NOentry#23"
os.environ["AWS_SSL_ENABLED"] = "TRUE"
os.environ["AWS_S3_ENDPOINT"] = "127.0.0.1:9000"

# Initialize Minio client
client = Minio(
    endpoint=os.environ["AWS_S3_ENDPOINT"],
    access_key=os.environ["AWS_ACCESS_KEY_ID"],
    secret_key=os.environ["AWS_SECRET_ACCESS_KEY"],
    secure=True,
    http_client=urllib3.PoolManager(cert_reqs='CERT_NONE')
)

# Get files from the MinIO server
bucket_name = 'templategenerator'

# Read the CSV file into a DataFrame
iris_csv = client.get_object('templategenerator', "iris.csv")
st.success("Data loaded successfully")

# Load the iris dataset into a Pandas DataFrame
iris_df = pd.read_csv(io.BytesIO(iris_csv.read()))

# Convert the Pandas DataFrame to a Spark DataFrame
iris_spark_df = spark.createDataFrame(iris_df)
    
# Show data
st.dataframe(iris_spark_df, selection_mode='multi-column')
