library(readr)
library(dplyr)
library(tidyr)

# input_path = "tfm/production/3-graphdb/4-output/"
# output_path = "tfm/production/4-evaluome/"

# ontoportal_mat_long_na.csv <- read_csv(paste(input_path,"ontoportal_mat_long_na.csv", sep=""), na = "NaN",show_col_types = FALSE)
# ontoportal_agro_long_na.csv <- read_csv(paste(input_path,"ontoportal_agro_long_na.csv", sep=""), na = "NaN",show_col_types = FALSE)
# ontoportal_mat_long_na.csv <- read_csv(paste(input_path,"ontoportal_mat_long_na.csv", sep=""), na = "NaN",show_col_types = FALSE)
# ontoportal_bio_long_na.csv <- read_csv(paste(input_path,"ontoportal_bio_long_na.csv", sep=""), na = "NaN",show_col_types = FALSE)
# ontoportal_biodiv_long_na.csv <- read_csv(paste(input_path,"ontoportal_biodiv_long_na.csv", sep=""), na = "NaN",show_col_types = FALSE)
# ontoportal_earth_long_na.csv <- read_csv(paste(input_path,"ontoportal_earth_long_na.csv", sep=""), na = "NaN",show_col_types = FALSE)
# qcoquo <- read_csv(paste(input_path,"qcoquo.csv", sep=""), na = "NaN",show_col_types = FALSE)

# ontoportal_all_repositories <- read_csv(paste(input_path,"ontoportal_all_repositories.csv", sep=""), na = "NaN",show_col_types = FALSE)
# metricAcronym <- ontoportal_all_repositories %>% select(metricAcronym, metricName) %>% distinct

#######
## Description:
## Allows to transform a GraphDB CSV file (‘long’ format, with ‘NA’ values), 
## into a CSV file suitable for processing by EvaluomeR (‘wide’ format and without ‘NA’ values).
## Arguments:
##    - inputPath: Directory path where the input files are located. 
##    - outputPath: Directory path where the output files are to be hosted
##    - repoAcronym: Short repository name. Examples: agro, eco, bio, biodiv, 
#######
graphDBToEvaluomeETL <- function(inputPath, outputPath, repoAcronym) {
  
  oquoMetricList=c("ANOnto","APWND","APWNN","APWNS","AROnto","CBOOnto","CROnto","CWND","CWNN","CWNS","DITOnto","DPWND","DPWNN","DPWNS","DxAP","DxC","DxDP","DxOP","DxP","INROnto","LCOMOnto","LRClassPCT","LRsxC","LSLD","NACOnto","NLR","NLRC","NOCOnto","NOMOnto","NxAP","NxC","NxDP","NxOP","NxP","OPWND","OPWNN","OPWNS","POnto","PROnto","RFCOnto","RROnto","SYSNAM","SxAP","SxC","SxDP","SxOP","SxP","TMOnto","TMOnto2","WMCOnto","WMCOnto2")
  print(oquoMetricList)
  outputPath <- paste0(outputPath, repoAcronym)
  print(outputPath)
#  if (!dir.exists(outputPath)) dir.create(outputPath, recursive = TRUE)
  
  inputFile <- paste0(inputPath,"ontoportal_",repoAcronym, "_long_na.csv")
  print(inputFile)
#  ontoportal_repo_long_na <- read.csv(inputFile, na = "NaN",stringsAsFactors = T)
  
#  ontoportal_repo_wide_na <- ontoportal_repo_long_na %>% spread(oquoMetricList, result)
#  names(ontoportal_repo_wide_na)[1] <- "Description"
  
#  ontoportal_repo_wide <- ontoportal_repo_wide_na[ , apply(ontoportal_repo_wide_na, 2, function(x) !any(is.na(x)))]
  
#  str(names(ontoportal_repo_wide))
  
#  write.csv(ontoportal_repo_wide, paste(output_path,"eco/ontoportal_eco_wide.csv", sep=""), row.names=FALSE)
#  write.csv(ontoportal_repo_wide_na, paste(output_path,"eco/ontoportal_eco_wide_na.csv", sep=""), row.names=FALSE)
}

graphDBToEvaluomeETL("~/tfm/production/4-evaluome/","~/tfm/production/3-graphdb/4-output/", "eco")

# ZONA ECO
ontoportal_eco_long_na <- read.csv(paste(input_path,"ontoportal_eco_long_na.csv", sep=""), na = "NaN",stringsAsFactors = T)

ontoportal_eco_wide_na <- ontoportal_eco_long_na %>% spread(metricAcronym, result)
names(ontoportal_eco_wide_na)[1] <- "Description"

ontoportal_eco_wide <- ontoportal_eco_wide_na[ , apply(ontoportal_eco_wide_na, 2, function(x) !any(is.na(x)))]

str(names(ontoportal_eco_wide))

write.csv(ontoportal_eco_wide, paste(output_path,"eco/ontoportal_eco_wide.csv", sep=""), row.names=FALSE)
write.csv(ontoportal_eco_wide_na, paste(output_path,"eco/ontoportal_eco_wide_na.csv", sep=""), row.names=FALSE)

# ZONA AGRO
ontoportal_eco_long_na <- read.csv(paste(input_path,"ontoportal_eco_long_na.csv", sep=""), na = "NaN",stringsAsFactors = T)

ontoportal_eco_wide_na <- ontoportal_eco_long_na %>% spread(metricAcronym, result)
names(ontoportal_eco_wide_na)[1] <- "Description"

ontoportal_eco_wide <- ontoportal_eco_wide_na[ , apply(ontoportal_eco_wide_na, 2, function(x) !any(is.na(x)))]

str(names(ontoportal_eco_wide))

write.csv(ontoportal_eco_wide, paste(output_path,"eco/ontoportal_eco_wide.csv", sep=""), row.names=FALSE)
write.csv(ontoportal_eco_wide_na, paste(output_path,"eco/ontoportal_eco_wide_na.csv", sep=""), row.names=FALSE)



