library(readr)
library(dplyr)
library(tidyr)

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
  print(sprintf("outputPath: %s",outputPath))
  
  if (!dir.exists(outputPath)) dir.create(outputPath, recursive = TRUE)
  
  inputFile <- paste0(inputPath,"ontoportal_",repoAcronym, "_long_na.csv")
  print(sprintf("inputFile: %s",inputFile))
  ontoportal_repo_long_na <- read.csv(inputFile, na = "NaN",stringsAsFactors = T)
    
  ontoportal_repo_wide_na <- ontoportal_repo_long_na %>% spread(metricAcronym, result)
  names(ontoportal_repo_wide_na)[1] <- "Description"

  #ontoportal_repo_wide <- ontoportal_repo_wide_na[ , apply(ontoportal_repo_wide_na, 2, function(x) !any(is.na(x)))]
  ontoportal_repo_wide <- removeAllNA(ontoportal_repo_wide_na)
  
  str(names(ontoportal_repo_wide))
  
  outputWideNaFile <- paste0(outputPath,"/ontoportal_", repoAcronym,"_wide_na.csv")
  print(sprintf("outputWideNaFile: %s",outputWideNaFile))
  outputWideFile <- paste0(outputPath,"/ontoportal_", repoAcronym,"_wide.csv")
  print(sprintf("outputWideFile: %s",outputWideFile))
  
  write.csv(ontoportal_repo_wide, outputWideFile, row.names=FALSE)
  write.csv(ontoportal_repo_wide_na, outputWideNaFile, row.names=FALSE)
}




input_path = "~/tfm/production/3-graphdb/4-output/"
output_path = "~/tfm/production/4-evaluome/"

graphDBToEvaluomeETL(input_path,output_path, "bio")
graphDBToEvaluomeETL(input_path,output_path, "agro")
graphDBToEvaluomeETL(input_path,output_path, "biodiv")
graphDBToEvaluomeETL(input_path,output_path, "earth")
graphDBToEvaluomeETL(input_path,output_path, "eco")
graphDBToEvaluomeETL(input_path,output_path, "ind")


