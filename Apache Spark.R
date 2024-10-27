# https://spark.apache.org/
# https://www.youtube.com/watch?v=qnINvPqcRvE
# docker run -it --rm spark:r /opt/spark/bin/sparkR
install.packages("sparklyr")
library(sparklyr)

# Local Spark Cluster
sparklyr::spark_install(version = "3.5.0")
sc <- spark_connect(master = "local")

# Spark Dataframe
iris_tbl <- copy_to(sc, iris)
