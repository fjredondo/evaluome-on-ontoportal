
# Get arguments
setwd('/home/jredondo/tfm/production/4-evaluome')


library(ggridges)
library(ggplot2)
library(egg)
library(dplyr)
library(tidyr)
library(evaluomeR)
library(tools)
library(factoextra)
library(corrplot)
library(RColorBrewer)
library(optparse)

####################
##### FUNCTIONS
####################


# Calculates the k range to be tested in evaluome for the given dataframe
calculateKRange <- function(df, bs, seed) {
  min_k = 2
  max_k = 15
  valid_k_range = FALSE
  while (!valid_k_range & min_k <= max_k){
    #cat(paste0("testing k range (", min_k, ", ", max_k, ")"))
    x = try(annotateClustersByMetric(df, k.range=c(min_k, max_k), bs=bs, seed=seed), silent = TRUE)
    if(class(x) != "try-error") {
      valid_k_range = TRUE
    } else {
      max_k = max_k - 1
    }
  }
  if (min_k > max_k) {
    return (NA)
  }
  return (c(min_k, max_k))
}

# Test the possible ranges for k for each metric. Return a named list
# where the key is the name of a metric, and the value is the wider k
# range that worked for evaluome. If no valid range was found, the
# value is NA.
getValidKRangesPerMetric <- function(df, bs, seed) {
  configs = list()
  # Remove first col as it is the name of the individual
  metric_names = df %>% select(-1) %>% colnames()
  for (metric_name in metric_names) {
    single_metric_df = df %>% select(1, !!metric_name)
    configs[[metric_name]] = calculateKRange(single_metric_df, bs, seed)
  }
  return(configs)
}

# Maximises the number of rows and columns after carrying out a complete removal of NAs
removeAllNA <- function(df) {
  #Check if there is NAs en el dataframe.
  while (!sum(is.na(df))==0){
    print (sum(is.na(df)))
    colMaxNA = max(apply(X = is.na(df), MARGIN = 2, FUN = mean))
    rowMaxNA = max(apply(X = is.na(df), MARGIN = 1, FUN = mean))
    
    if (colMaxNA > rowMaxNA){
      #There is high percentage of NAs in column
      print (which.max(colSums(is.na(df))))
      df = df[,-which.max(colSums(is.na(df)))]
    }else{
      print (which.max(rowSums(is.na(df))))
      df = df[-which.max(rowSums(is.na(df))),]
    }
  }
  return(df)
}

# Transform input value in a range [minInput, maxInput] to a range [minOutput, maxOutput]
normalizeNegativeRange <-  function(input, minInput, maxInput, minOutput, maxOutput)
{
  return (((input - minInput) / (maxInput - minInput)) * 
            (maxOutput - minOutput) + minOutput);
}


####################
##### Discriminatory Index 
####################


repoAcronym = "ind"

input <- paste0("./", repoAcronym,"/ontoportal_", repoAcronym,"_wide.csv")
optimalKFile <- paste0("./", repoAcronym, "/output","/ontoportal_", repoAcronym,"_optimal_k.csv")

# Get metrics file
all = read.csv2(input, header = T, sep = ",", na.strings = "NaN", stringsAsFactors = F)
#colnames(all) = c('Ontology','Metric','Value')


sapply(all, class)

cols.num <- colnames(all[-1])
all[cols.num] <- sapply(all[cols.num],as.numeric)
sapply(all, class)


# Evaluome params for searching the optimal k of each metric.
bs = 20
seed = 100
# Calculate, for each metric, the k range in which evaluome does not crash.
kranges_per_metric = getValidKRangesPerMetric(all, bs=bs, seed=seed)
# Select the minimal k range found and remove the metrics that could not be partitioned
k.range = NULL
for (metric_name in names(kranges_per_metric)) {
  if (length(kranges_per_metric[[metric_name]]) == 1 && is.na(kranges_per_metric[[metric_name]])){
    warning(cat('The metric', metric_name, 'cannot be splited into subgroups. Ignoring...\n'))
    all = all %>% select(-!!metric_name)
  } else if(is.null(k.range) || kranges_per_metric[[metric_name]][2] < k.range[2]) {
    k.range = kranges_per_metric[[metric_name]]
  }
}

all_metrics = colnames(all)[2:length(colnames(all))]

x = annotateClustersByMetric(all, k.range=k.range, bs=bs, seed=seed)
stability_data = as.data.frame(assay(x[['stability_data']]))
quality_data = x[['quality_data']]
kOptTable <- getOptimalKValue(stability_data, quality_data)

kOptTable <- kOptTable %>% 
  mutate(Discriminatory_index = Quality_max_k_stab * normalizeNegativeRange(Quality_max_k_qual,-1,1,0,1))


write.csv(kOptTable, optimalKFile, row.names=FALSE)

