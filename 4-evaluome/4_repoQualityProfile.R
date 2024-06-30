# Get arguments
setwd('/home/jredondo/tfm/production/4-evaluome')


# load lsa module (cosine)
library(lsa)
library(pheatmap)
library(RColorBrewer)
####################
##### FUNCTIONS
####################

# apply_cosine_similarity <- function(df){
#   cos.sim <- function(df, ix) 
#   {
#     
#     A = df[ix[1],]
#     B = df[ix[2],]
#     print(ix[1])
#     print (A)
#     return( sum(A*B)/sqrt(sum(A^2)*sum(B^2)) )
#   }   
#   n <- nrow(df) 
#   cmb <- expand.grid(i=1:n, j=1:n) 
#   
#   C <- matrix(apply(cmb,1,function(cmb){ cos.sim(df, cmb) }),n,n)
#   C
# }


####################
##### Cosine similarity
####################

setwd('/home/jredondo/tfm/production/4-evaluome')
repolist <- c("agro", "bio", "biodiv","earth","eco","ind")

optimalK = read.csv2("./0_metricAcronymList_evaluome.csv", header = T, sep = ",", na.strings = "NaN", stringsAsFactors = T)


agroDF = read.csv2("./agro/output/ontoportal_agro_optimal_k.csv", header = T, sep = ",", na.strings = "NaN", stringsAsFactors = T)
agroDF <- agroDF[,c(1,8)]
colnames(agroDF)[2] <- "AgroPortal"
bioDF = read.csv2("./bio/output/ontoportal_bio_optimal_k.csv", header = T, sep = ",", na.strings = "NaN", stringsAsFactors = T)
bioDF <- bioDF[,c(1,8)]
colnames(bioDF)[2] <- "BioPortal"
biodivDF = read.csv2("./biodiv/output/ontoportal_biodiv_optimal_k.csv", header = T, sep = ",", na.strings = "NaN", stringsAsFactors = T)
biodivDF <- biodivDF[,c(1,8)]
colnames(biodivDF)[2] <- "BiodivPortal"
earthDF = read.csv2("./earth/output/ontoportal_earth_optimal_k.csv", header = T, sep = ",", na.strings = "NaN", stringsAsFactors = T)
earthDF <- earthDF[,c(1,8)]
colnames(earthDF)[2] <- "EarthPortal"
ecoDF = read.csv2("./eco/output/ontoportal_eco_optimal_k.csv", header = T, sep = ",", na.strings = "NaN", stringsAsFactors = T)
ecoDF <- ecoDF[,c(1,8)]
colnames(ecoDF)[2] <- "EcoPortal"
indDF = read.csv2("./ind/output/ontoportal_ind_optimal_k.csv", header = T, sep = ",", na.strings = "NaN", stringsAsFactors = T)
indDF <- indDF[,c(1,8)]
colnames(indDF)[2] <- "IndustryPortal"

optimalK <- merge(optimalK, agroDF, by = "Metric", all.x = TRUE) 
optimalK <- merge(optimalK, bioDF, by = "Metric", all.x = TRUE) 
optimalK <- merge(optimalK, biodivDF, by = "Metric", all.x = TRUE) 
optimalK <- merge(optimalK, earthDF, by = "Metric", all.x = TRUE) 
optimalK <- merge(optimalK, ecoDF, by = "Metric", all.x = TRUE) 
optimalK <- merge(optimalK, indDF, by = "Metric", all.x = TRUE) 

#write.csv(optimalK,"./output/ontoportal_optimal_k_with_na.csv", row.names=FALSE)

optimalK <- na.omit(optimalK)
#write.csv(optimalK,"./output/ontoportal_optimal_k.csv", row.names=FALSE)

optimalK <- data.frame(optimalK[,-1], row.names=optimalK[,1])
tOptimalK <- data.frame(t(optimalK))

# repoCosineSimilarity <- apply_cosine_similarity(tOptimalK)

#df[df > 0] <- 1
#df[df <= 0] <- 0


# create vectors
AgroPortal = optimalK[,1]
BioPortal = optimalK[,2]
BiodivPortal = optimalK[,3]
EarthPortal = optimalK[,4]
EcoPortal = optimalK[,5]
IndPortal = optimalK[,6]

# create a matrix using cbind() function 
final = cbind(AgroPortal, BioPortal, BiodivPortal, EarthPortal, EcoPortal, IndPortal) 

# save cosine similarity in a matrix 
write.csv(cosine(final),"./output/ontoportal_cosine_similarity.csv", row.names=FALSE)

pheatmap(cosine(final), display_numbers=T, show_rownames = T, show_colnames = F)

pheatmap(cosine(final), display_numbers=T,
         show_rownames = T,
         show_colnames = F, 
         filename = "output/img/ontoportal_cosine_similarity.png")



######
# índice discriminatorio.
######


discIndex = read.csv2("./0_metricAcronymList_evaluome.csv", header = T, sep = ",", na.strings = "NaN", stringsAsFactors = T)


agroDF = read.csv2("./agro/output/ontoportal_agro_optimal_k.csv", header = T, sep = ",", na.strings = "NaN", stringsAsFactors = F)
agroDF <- agroDF[,c(1,9)]
agroDF[, 2]  <- as.numeric(agroDF[, 2])
colnames(agroDF)[2] <- "AgroPortal"
bioDF = read.csv2("./bio/output/ontoportal_bio_optimal_k.csv", header = T, sep = ",", na.strings = "NaN", stringsAsFactors = F)
bioDF <- bioDF[,c(1,9)]
bioDF[, 2]  <- as.numeric(bioDF[, 2])
colnames(bioDF)[2] <- "BioPortal"
biodivDF = read.csv2("./biodiv/output/ontoportal_biodiv_optimal_k.csv", header = T, sep = ",", na.strings = "NaN", stringsAsFactors = F)
biodivDF <- biodivDF[,c(1,9)]
biodivDF[, 2]  <- as.numeric(biodivDF[, 2])
colnames(biodivDF)[2] <- "BiodivPortal"
earthDF = read.csv2("./earth/output/ontoportal_earth_optimal_k.csv", header = T, sep = ",", na.strings = "NaN", stringsAsFactors = F)
earthDF <- earthDF[,c(1,9)]
earthDF[, 2]  <- as.numeric(earthDF[, 2])
colnames(earthDF)[2] <- "EarthPortal"
ecoDF = read.csv2("./eco/output/ontoportal_eco_optimal_k.csv", header = T, sep = ",", na.strings = "NaN", stringsAsFactors = F)
ecoDF <- ecoDF[,c(1,9)]
ecoDF[, 2]  <- as.numeric(ecoDF[, 2])
colnames(ecoDF)[2] <- "EcoPortal"
indDF = read.csv2("./ind/output/ontoportal_ind_optimal_k.csv", header = T, sep = ",", na.strings = "NaN", stringsAsFactors = F)
indDF <- indDF[,c(1,9)]
indDF[, 2]  <- as.numeric(indDF[, 2])
colnames(indDF)[2] <- "IndustryPortal"

discIndex <- merge(discIndex, agroDF, by = "Metric", all.x = TRUE) 
discIndex <- merge(discIndex, bioDF, by = "Metric", all.x = TRUE) 
discIndex <- merge(discIndex, biodivDF, by = "Metric", all.x = TRUE) 
discIndex <- merge(discIndex, earthDF, by = "Metric", all.x = TRUE) 
discIndex <- merge(discIndex, ecoDF, by = "Metric", all.x = TRUE) 
discIndex <- merge(discIndex, indDF, by = "Metric", all.x = TRUE) 

#write.csv(discIndex,"./output/ontoportal_optimal_k_with_na.csv", row.names=FALSE)

discIndex <- data.frame(discIndex[,-1], row.names=discIndex[,1])


######
# Variante del índice discriminatorio sin filtrado de los valores NA.
######


discIndexNoNA <- round(discIndex,3)
discIndexNoNA[discIndexNoNA ==0] <- NA

discIndexNoNA[is.na(discIndexNoNA)] <- ""


bk <- c(seq(0.42,1,by=0.01))

pheatmap(t(discIndex), 
         display_numbers=t(discIndexNoNA),
         clustering_method = "complete", 
         cluster_rows = TRUE, 
         cluster_cols = FALSE,
         clustering_distance_rows = "euclidean",
         show_rownames = TRUE,
         cellheight = NA, cellwidth = NA,
         na_col = "#FFFFFF",
         color=colorRampPalette(c("#F8696B", "white", "#9BD5AA"))(59),
         cutree_rows = 3,
         breaks = bk,
         border_color = "#F2F2F2",
         fontsize_row = 10, angle_col = 90, fontsize_for_colnames = 10)




######
# Variante del índice discriminatorio una vez filtrados los valores NA.
######

discIndex <- na.omit(discIndex)
discIndex <- data.frame(discIndex[,-1], row.names=discIndex[,1])
discIndexChar <- round(discIndex,3)
discIndexChar[1:6] <- sapply(discIndexChar[1:6],as.character)


pheatmap(t(discIndex), 
         display_numbers=t(discIndexChar),
         clustering_method = "complete", 
         cluster_rows = FALSE, 
         cluster_cols = TRUE,
         clustering_distance_rows = "euclidean",
         show_rownames = TRUE,
         cellheight = NA, cellwidth = NA,
         na_col = "#FFFFFF",
         color=colorRampPalette(c("#F8696B", "white", "#9BD5AA"))(59),
         cutree_rows = 2, cutree_cols = 2,
         breaks = bk,
         border_color = "#F2F2F2",
         fontsize_row = 10, angle_col = 90, fontsize_for_colnames = 10)


######
# Variante optimal k.
######

tOptimalK[tOptimalK ==0] <- NA

tOptimalK[is.na(tOptimalK)] <- ""


pheatmap(t(discIndex), 
         display_numbers=tOptimalK,
         clustering_method = "complete", 
         cluster_rows = TRUE, 
         cluster_cols = FALSE,
         clustering_distance_rows = "euclidean",
         show_rownames = TRUE,
         cellheight = NA, cellwidth = NA,
         na_col = "#FFFFFF",
         color=colorRampPalette(c("#F8696B", "white", "#9BD5AA"))(59),
         cutree_rows = 2, cutree_cols = 2,
         breaks = bk,
         border_color = "#F2F2F2",
         fontsize_row = 10, angle_col = 90, fontsize_for_colnames = 10)






















