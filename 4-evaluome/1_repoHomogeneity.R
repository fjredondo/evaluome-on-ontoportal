
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


# Función para el cálculo del coeficiente de variación de Pearson.
# Si el coeficiente de variación de una variable es mayor que 0.5, entonces su media no es 
# representativa. Por el contrario, si es menor que 0.5, si es representativa. 


CVar<-function(x)
{
  resultado<-sqrt(var(x))/abs(mean(x))
  return(resultado)
}

####################
##### Cosine similarity
####################

setwd('/home/jredondo/tfm/production/4-evaluome')
#repolist <- c("agro", "bio", "biodiv","earth","eco","ind")

repoCVar = read.csv2("./0_metricAcronymList.csv", header = T, sep = ",", na.strings = "NaN", stringsAsFactors = T)

agroDF = read.csv2("./agro/ontoportal_agro_wide.csv", header = T, sep = ",", na.strings = "NaN", stringsAsFactors = F)
cols.num <- colnames(agroDF[-1])
agroDF[cols.num] <- sapply(agroDF[cols.num],as.numeric)
agroDF <- as.data.frame(apply(agroDF[,-1],2, CVar))
colnames(agroDF)[1] <- "AgroPortal"
agroDF <- cbind(rownames(agroDF), data.frame(agroDF, row.names=NULL))
colnames(agroDF)[1] <- "Metric"


bioDF = read.csv2("./bio/ontoportal_bio_wide.csv", header = T, sep = ",", na.strings = "NaN", stringsAsFactors = F)
cols.num <- colnames(bioDF[-1])
bioDF[cols.num] <- sapply(bioDF[cols.num],as.numeric)
bioDF <- as.data.frame(apply(bioDF[,-1],2, CVar))
colnames(bioDF)[1] <- "BioPortal"
bioDF <- cbind(rownames(bioDF), data.frame(bioDF, row.names=NULL))
colnames(bioDF)[1] <- "Metric"

biodivDF = read.csv2("./biodiv/ontoportal_biodiv_wide.csv", header = T, sep = ",", na.strings = "NaN", stringsAsFactors = F)
cols.num <- colnames(biodivDF[-1])
biodivDF[cols.num] <- sapply(biodivDF[cols.num],as.numeric)
biodivDF <- as.data.frame(apply(biodivDF[,-1],2, CVar))
colnames(biodivDF)[1] <- "BiodivPortal"
biodivDF <- cbind(rownames(biodivDF), data.frame(biodivDF, row.names=NULL))
colnames(biodivDF)[1] <- "Metric"

earthDF = read.csv2("./earth/ontoportal_earth_wide.csv", header = T, sep = ",", na.strings = "NaN", stringsAsFactors = F)
cols.num <- colnames(earthDF[-1])
earthDF[cols.num] <- sapply(earthDF[cols.num],as.numeric)
earthDF <- as.data.frame(apply(earthDF[,-1],2, CVar))
colnames(earthDF)[1] <- "EarthPortal"
earthDF <- cbind(rownames(earthDF), data.frame(earthDF, row.names=NULL))
colnames(earthDF)[1] <- "Metric"

ecoDF = read.csv2("./eco/ontoportal_eco_wide.csv", header = T, sep = ",", na.strings = "NaN", stringsAsFactors = F)
cols.num <- colnames(ecoDF[-1])
ecoDF[cols.num] <- sapply(ecoDF[cols.num],as.numeric)
ecoDF <- as.data.frame(apply(ecoDF[,-1],2, CVar))
colnames(ecoDF)[1] <- "EcoPortal"
ecoDF <- cbind(rownames(ecoDF), data.frame(ecoDF, row.names=NULL))
colnames(ecoDF)[1] <- "Metric"

indDF = read.csv2("./ind/ontoportal_ind_wide.csv", header = T, sep = ",", na.strings = "NaN", stringsAsFactors = F)
cols.num <- colnames(indDF[-1])
indDF[cols.num] <- sapply(indDF[cols.num],as.numeric)
indDF <- as.data.frame(apply(indDF[,-1],2, CVar))
colnames(indDF)[1] <- "IndustryPortal"
indDF <- cbind(rownames(indDF), data.frame(indDF, row.names=NULL))
colnames(indDF)[1] <- "Metric"

repoCVar <- merge(repoCVar, agroDF, by = "Metric", all.x = TRUE) 
repoCVar <- merge(repoCVar, bioDF, by = "Metric", all.x = TRUE) 
repoCVar <- merge(repoCVar, biodivDF, by = "Metric", all.x = TRUE) 
repoCVar <- merge(repoCVar, earthDF, by = "Metric", all.x = TRUE) 
repoCVar <- merge(repoCVar, ecoDF, by = "Metric", all.x = TRUE) 
repoCVar <- merge(repoCVar, indDF, by = "Metric", all.x = TRUE) 

write.csv(repoCVar,"./output/ontoportal_cvar_with_na.csv", row.names=FALSE)

repoCVar <- na.omit(repoCVar)
write.csv(repoCVar,"./output/ontoportal_cvar.csv", row.names=FALSE)


repoCVar <- data.frame(repoCVar[,-1], row.names=repoCVar[,1])

pheatmap(repoCVar, display_numbers=T, show_rownames = T, show_colnames = T)


trepoCVar <- data.frame(t(repoCVar))

# repoCosineSimilarity <- apply_cosine_similarity(tOptimalK)

#df[df > 0] <- 1
#df[df <= 0] <- 0


# create vectors
AgroPortal = repoCVar[,1]
BioPortal = repoCVar[,2]
BiodivPortal = repoCVar[,3]
EarthPortal = repoCVar[,4]
EcoPortal = repoCVar[,5]
IndPortal = repoCVar[,6]

# create a matrix using cbind() function 
final = cbind(AgroPortal, BioPortal, BiodivPortal, EarthPortal, EcoPortal, IndPortal) 

# save cosine similarity in a matrix 
write.csv(cosine(final),"./output/ontoportal_cvar_cosine_similarity.csv", row.names=FALSE)

pheatmap(cosine(final), display_numbers=T, show_rownames = T, show_colnames = F)

pheatmap(cosine(final), display_numbers=T,
         show_rownames = T,
         show_colnames = F, 
         filename = "output/img/ontoportal_cvar_cosine_similarity.png")

pheatmap(repoCVar, display_numbers=T, 
         show_rownames = T, 
         show_colnames = T,
         filename = "output/img/ontoportal_cvar_heatmap.png")


dev.off













max(unname(at_CVAR)) + 0.1
barra <- barplot(at_CVAR, names.arg = colnames(at_data[,-36]), 
                 main = "Coeficiente de Variación de Pearson",
                 ylim =c(0,max(unname(at_CVAR)) + 0.02),
                 density =c(0))

text(barra,  unname(at_CVAR) + 0.01 ,round(unname(at_CVAR),2) ,cex=1) 


tapply(at_data[,-36], at_data$Description, summary)

apply(at_data[,-36], 2, var)
apply(at_data[,-36], 2, sd)
apply(at_data[,-36], 2, mean)


