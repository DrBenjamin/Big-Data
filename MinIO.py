import os
import io
import urllib3
from minio import Minio
import pandas as pd
import matplotlib.pyplot as plt

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

# Read the CSV file from MinIO
csv_object = client.get_object(bucket_name, 'options.csv')
csv_data = pd.read_csv(io.BytesIO(csv_object.read()), quotechar="'")
print(csv_data.head())

# Read the image file from MinIO
image_object = client.get_object(bucket_name, 'Ben.jpg')
image_data = plt.imread(io.BytesIO(image_object.read()), format='jpg')
plt.imshow(image_data)
plt.axis('off')
plt.show()