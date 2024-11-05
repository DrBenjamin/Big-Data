# Big-Data

Big Data course

## Knitting files

Creating PDFs from markdown files.

### Knitting the Rmd file

```bash
Rscript -e "rmarkdown::render('Introduction to sparklyr.Rmd')"
```

### Knitting the qmd file

```bash
# Render the file to pdf
quarto render Apache\ Spark.qmd --to pdf --execute

# Converting jupyter notebook to qmd
quarto convert Apache\ Spark.ipynb

# Converting qmd to jupyter notebook
quarto convert Apache\ Spark.qmd
```

## ETL

Follow the tutorial on [LinkedIn Learning](https://www.linkedin.com/learning/etl-in-python-and-sql/create-an-etl-in-python-and-sql?resume=false&u=50251009).

### PostgreSQL

```bash
# Create the database
createdb etl
psql etl

# Create user and grant privileges
CREATE USER etl WITH PASSWORD 'eTl';
GRANT ALL PRIVILEGES ON DATABASE etl TO etl;
```

### Apache Airflow

Initialize Apache Airflow.

```bash
airflow db init
airflow users create -u admin -p NOentry#23 -e drdrbenjamin@icloud.com -r Admin -f Benjamin -l Gross
airflow webserver --port 8080
airflow scheduler
```

See [StackOverflow](https://stackoverflow.com/questions/38332787/pandas-to-sql-to-sqlite-returns-engine-object-has-no-attribute-cursor) for error with SQLAlchemy.