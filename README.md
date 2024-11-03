# Big-Data

Big Data course

## Knitting the Rmd file

```bash
Rscript -e "rmarkdown::render('Introduction to sparklyr.Rmd')"
```

## Knitting the qmd file

```bash
# Render the file to pdf
quarto render Apache\ Spark.qmd --to pdf --execute

# Converting jupyter notebook to qmd
quarto convert Apache\ Spark.ipynb

# Converting qmd to jupyter notebook
quarto convert Apache\ Spark.qmd
```