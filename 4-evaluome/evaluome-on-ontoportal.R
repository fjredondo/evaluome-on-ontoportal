library(readr)
library(dplyr)
library(tidyr)

csv_path = "tfm/production/3-evaluome/graphdb_downloads/20240530/"

ontoportal_mat <- read_csv(paste(csv_path,"ontoportal_mat.csv", sep=""), na = "NaN",show_col_types = FALSE)
ontoportal_eco <- read_csv(paste(csv_path,"ontoportal_eco.csv", sep=""), na = "NaN",show_col_types = FALSE)
ontoportal_agro <- read_csv(paste(csv_path,"ontoportal_agro.csv", sep=""), na = "NaN",show_col_types = FALSE)
ontoportal_ind <- read_csv(paste(csv_path,"ontoportal_ind.csv", sep=""), na = "NaN",show_col_types = FALSE)
ontoportal_bio <- read_csv(paste(csv_path,"ontoportal_bio.csv", sep=""), na = "NaN",show_col_types = FALSE)
ontoportal_biodiv <- read_csv(paste(csv_path,"ontoportal_biodiv.csv", sep=""), na = "NaN",show_col_types = FALSE)
ontoportal_earth <- read_csv(paste(csv_path,"ontoportal_earth.csv", sep=""), na = "NaN",show_col_types = FALSE)
ontoportal_all_repositories <- read_csv(paste(csv_path,"ontoportal_all_repositories.csv", sep=""), na = "NaN",show_col_types = FALSE)
qcoquo <- read_csv(paste(csv_path,"qcoquo.csv", sep=""), na = "NaN",show_col_types = FALSE)

ontoportal_prueba <- read_csv(paste(csv_path,"ontoportal_prueba.csv", sep=""), na = "NaN",show_col_types = FALSE)


metricAcronym <- ontoportal_all_repositories %>% select(metricAcronym) %>% distinct

ontoportal_prueba_spread <- 

  

group_by(Scale, ID) %>%                     # for each combination of Scale and ID
  mutate(names = c("x","y","z","a","b")) %>%  # add column names
  ungroup() %>%                               # forget the grouping
  spread(-Scale, -ID) %>%                     # reshape data
  select(Scale, ID, x, y, z, a, b)            # order columns



stocks <- tibble(
  time = as.Date("2009-01-01") + 0:9,
  X = rnorm(10, 0, 1),
  Y = rnorm(10, 0, 2),
  Z = rnorm(10, 0, 4)
)

stocksm <- stocks %>% gather(stock, price, -time)
stocksm %>% spread(stock, price)
stocksm %>% spread(time, price)


ontoportal_prueba %>% spread(metricAcronym, result)


# step2_78_agro_ontologies <- read_csv("tfm/production/3-evaluome/examples/step2-78-agro-ontologies.csv")
# 
# data("step2_78_agro_ontologies")
# 
# 
# data("ontMetrics")
# 
# str(ontMetrics)
# str(step2_78_agro_ontologies)
# 
# cor = metricsCorrelations(ontMetrics, getImages = TRUE, margins = c(1,0,5,11))
# 
# colData <- data.frame(metrics=factor(c("Description", "ANOnto", "AROnto","CBOOnto")))
# 
# 
# se <- SummarizedExperiment()
# 
# colData
# 
# ontMetrics.rowData
# 
# ontMetrics@assays
# l <- assay(ontMetrics, 1)
# 
# str(l)
# 
# assayNames(ontMetrics)
# df <- rowData(ontMetrics)
# colData(ontMetrics)
# rowRanges(rse)
# ontMetrics$metrics
# 
# globalMetric(ontMetrics, k.range=c(2,5))
# 
# globalMetric(ontMetrics, k.range = c(2,3), nrep=10, criterion="AIC", PCA=TRUE)
# 
# cor = metricsCorrelations(ontMetrics, getImages = TRUE, margins = c(1,0,5,11))
# 
# plotMetricsBoxplot(ontMetrics)


result = quality(ontMetrics, k=4)

