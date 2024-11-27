# The R in Spark
library(sparklyr)
library(DBI)
library(dplyr)
library(corrr)
library(ggplot2)
library(dbplot)

# Creating a Spark Connection
sc <- spark_connect(master = "local", version = "3.5")
cars <- copy_to(sc, mtcars)

# Summarizing data - mean
cars %>%
  summarize_all(mean)

# Summarizing data - mean - show query
cars %>%
  summarise_all(mean) %>%
  show_query()

# Summarizing data - mean - SQL query
dbGetQuery(sc,
  "SELECT
    AVG(`mpg`) AS `mpg`,
    AVG(`cyl`) AS `cyl`,
    AVG(`disp`) AS `disp`,
    AVG(`hp`) AS `hp`,
    AVG(`drat`) AS `drat`,
    AVG(`wt`) AS `wt`,
    AVG(`qsec`) AS `qsec`,
    AVG(`vs`) AS `vs`,
    AVG(`am`) AS `am`,
    AVG(`gear`) AS `gear`,
    AVG(`carb`) AS `carb`
    FROM `mtcars`"
)

# Summarizing data - grouping / mean - show query
cars %>%
  mutate(transmission = ifelse(am == 0, "automatic", "manual")) %>%
  group_by(transmission) %>%
  summarise_all(mean)

# Summarizing data - percentile (Hive SQL function) - SQL query
cars %>%
  summarise(mpg_percentile = percentile(mpg, 0.25))
cars %>%
  summarise(mpg_percentile = percentile(mpg, 0.25)) %>%
  show_query()

# Summarizing data - percentile / array (Hive SQL functions) - SQL query
cars %>%
  summarise(mpg_percentile = percentile(mpg, array(0.25, 0.5, 0.75)))
cars %>%
  summarise(mpg_percentile = percentile(mpg, array(0.25, 0.5, 0.75))) %>%
  mutate(mpg_percentile = explode(mpg_percentile))

# Correlations
cars %>%
  ml_corr()

# Using `corrr` package
cars %>%
  correlate(use = "pairwise.complete.obs", method = "pearson")
cars %>%
  correlate(use = "pairwise.complete.obs", method = "pearson") %>%
  shave() %>%
  rplot()

# Plotting
cars %>%
  ggplot(aes(as.factor(cyl), mpg)) +
  geom_col()

# Collecting data from the spark cluster
car_group <- cars %>%
  group_by(cyl) %>%
  summarise(mpg = sum(mpg, na.rm = TRUE)) %>%
  collect() %>%
  print()
car_group %>% ggplot(aes(as.factor(cyl), mpg)) +
  geom_col(fill = "#999999") +
  coord_flip()

# Plotting with remote data (dbplot)
cars %>%
  dbplot_histogram(mpg, binwidth = 3) +
  labs(title = "MPG Distribution",
       subtitle = "Histogram over miles per gallon")
cars %>%
  ggplot(aes(mpg, wt)) +
  geom_point()
cars %>%
  dbplot_raster(mpg, wt, resolution = 16)

# Modelling
cars %>%
  ml_linear_regression(mpg ~ .) %>%
  summary()

# Caching
cached_cars <- cars %>%
  mutate(cyl = paste0("cyl_", cyl)) %>%
  compute("cached_cars")
cached_cars %>%
  ml_linear_regression(mpg ~ .) %>%
  summary()

# Disconnecting from spark cluster
spark_disconnect(sc)
