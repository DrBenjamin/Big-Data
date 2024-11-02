# Python script
import streamlit as st
# Import the SparkSession module
from pyspark.sql import SparkSession
import sys
import requests

# Streamlit Title
st.title("Streamlit with PySpark")

# Show Python Version
st.write(sys.version)

# Create a SparkSession
spark = SparkSession.builder.config("spark.hadoop.fs.s3a.aws.credentials.provider", "org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider").getOrCreate()
st.success("SparkSession created successfully")

# Get the SparkContext from the SparkSession
sc = spark.sparkContext
st.success("SparkContext retreived successfully")

# Set the MinIO access key, secret key, endpoint, and other configurations
sc._jsc.hadoopConfiguration().set("fs.s3a.access.key", "HEALTH")
sc._jsc.hadoopConfiguration().set("fs.s3a.secret.key", "NOentry#23")
sc._jsc.hadoopConfiguration().set("fs.s3a.endpoint", "https://localhost:9000")
sc._jsc.hadoopConfiguration().set("fs.s3a.path.style.access", "true")
sc._jsc.hadoopConfiguration().set("fs.s3a.connection.ssl.enabled", "false")
sc._jsc.hadoopConfiguration().set("fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem")
sc._jsc.hadoopConfiguration().set("fs.s3a.connection.ssl.enabled", "false")
st.success("MinIO configurations set successfully")

# Read a JSON file from an MinIO bucket using the access key, secret key, 
# and endpoint configured above
#url = "https://localhost:9000/templategenerator/file.json"
#response = requests.get(url)
#with open("/tmp/file.json", "wb") as f:
#    f.write(response.content)
df = spark.read.option("header", "false").json(f"s3a://templategenerator/file.json")
st.success("Data loaded successfully")
    
# Show data
st.dataframe(df, selection_mode='multi-column')
