library(readr)
library(dplyr)
library(tidyr)

input_path = "tfm/production/3-graphdb/4-output/20240601/"
output_path = "tfm/production/4-evaluome/eco/"

# ontoportal_mat <- read_csv(paste(input_path,"ontoportal_mat.csv", sep=""), na = "NaN",show_col_types = FALSE)
# ontoportal_agro <- read_csv(paste(input_path,"ontoportal_agro.csv", sep=""), na = "NaN",show_col_types = FALSE)
# ontoportal_ind <- read_csv(paste(input_path,"ontoportal_ind.csv", sep=""), na = "NaN",show_col_types = FALSE)
# ontoportal_bio <- read_csv(paste(input_path,"ontoportal_bio.csv", sep=""), na = "NaN",show_col_types = FALSE)
# ontoportal_biodiv <- read_csv(paste(input_path,"ontoportal_biodiv.csv", sep=""), na = "NaN",show_col_types = FALSE)
# ontoportal_earth <- read_csv(paste(input_path,"ontoportal_earth.csv", sep=""), na = "NaN",show_col_types = FALSE)
# qcoquo <- read_csv(paste(input_path,"qcoquo.csv", sep=""), na = "NaN",show_col_types = FALSE)

ontoportal_all_repositories <- read_csv(paste(input_path,"ontoportal_all_repositories.csv", sep=""), na = "NaN",show_col_types = FALSE)
metricAcronym <- ontoportal_all_repositories %>% select(metricAcronym, metricName) %>% distinct

ontoportal_eco_long_na <- read.csv(paste(input_path,"ontoportal_eco.csv", sep=""), na = "NaN",stringsAsFactors = T)

ontoportal_eco_wide_na <- ontoportal_eco_long_na %>% spread(metricAcronym, result)
names(ontoportal_eco_wide_na)[1] <- "Description"


ontoportal_eco_wide <- ontoportal_eco_wide_na[ , apply(ontoportal_eco_wide_na, 2, function(x) !any(is.na(x)))]

str(names(ontoportal_eco_wide))

write.csv(ontoportal_eco_wide, paste(output_path,"ontoportal_eco_wide.csv", sep=""), row.names=FALSE)
write.csv(ontoportal_eco_wide_na, paste(output_path,"ontoportal_eco_wide_na.csv", sep=""), row.names=FALSE)



