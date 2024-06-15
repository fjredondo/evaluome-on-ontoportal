# Get arguments
setwd('/home/jredondo/tfm/production/4-evaluome')


# load lsa module (cosine)
library(lsa)
library(pheatmap)

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

optimalK = read.csv2("./0_metricAcronymList.csv", header = T, sep = ",", na.strings = "NaN", stringsAsFactors = T)


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

write.csv(optimalK,"./output/ontoportal_optimal_k_with_na.csv", row.names=FALSE)

optimalK <- na.omit(optimalK)
write.csv(optimalK,"./output/ontoportal_optimal_k.csv", row.names=FALSE)

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

pheatmap(cosine(final), display_numbers=T,
         show_rownames = T,
         show_colnames = F, 
         filename = "output/img/ontoportal_cosine_similarity.png")

























