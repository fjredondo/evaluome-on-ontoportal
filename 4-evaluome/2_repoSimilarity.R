#library(devtools)
#install_github("fanavarro/evaluomeR")
#install_github("neobernad/evaluomeR")

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

getStabilityInterpretation <- function(x) {
  if (x < 0.60){
    return("Unstable")
  }
  if (x <= 0.75){
    return("Doubtful")
  }
  if (x <= 0.85){
    return("Stable")
  }
  if (x <= 1){
    return("Highly stable")
  }
}

getQualityInterpretation <- function(x) {
  if (x < 0.25){
    return("No structure")
  }
  if (x <= 0.50){
    return("Weak structure")
  }
  if (x <= 0.70){
    return("Reasonable structure")
  }
  if (x <= 1){
    return("Strong structure")
  }
}

# Receives the data and the name of a metric and prints a density plot, including
# each individual as a point.
printDensityPlotWithPoints <- function(data, metric) {
  aux = na.omit(data[[metric]])
  aux$cluster = as.character(aux$cluster)
  ggplot(aux, aes(x = .data[[metric]], y = 1, fill = cluster, point_color = cluster)) +
    geom_density_ridges(jittered_points = TRUE, size = 0.2, alpha = 0.4, stat = "density_ridges", panel_scaling=F) +
    theme_ridges() +
    ylab('Density')
}

# Receives the data, the name of a metric, a value of k, the stability data,
# the quality data and the metric ranges, and makes a plot including these data.
printDensityPlotWithPointsAndInfo <- function(data, metric, k, stability_data, quality_data, metric_ranges){
  stability_row_name = paste('Mean_stability_k_', k, sep='')
  stability_k = as.numeric(stability_data %>% filter(Metric == metric_name) %>% pull(!!sym(stability_row_name)))
  quality_col_name = paste('k_', k, sep = '')
  quality_k = as.data.frame(assay(quality_data[[quality_col_name]])) %>% filter(Metric == metric_name) %>% pull(Avg_Silhouette_Width) %>% as.numeric()
  annotationText = paste('Stability = ', format(round(stability_k, 3), nsmall = 3), '-', getStabilityInterpretation(stability_k), '\nQuality = ', format(round(quality_k, 3), nsmall = 3), '-', getQualityInterpretation(quality_k))
  aux = na.omit(x[[metric_name]][[as.character(k)]])
  aux$cluster = as.character(aux$cluster)
  # points to draw vertical lines
  cutpoints = c(metric_ranges[[as.character(k)]] %>% filter(metric==metric_name) %>% pull(min_value), metric_ranges[[as.character(k)]] %>% filter(metric==metric_name) %>% pull(max_value))
  plot = ggplot(aux, aes(x = .data[[metric_name]], y = 1, fill = cluster, point_color = cluster)) +
    geom_density_ridges(jittered_points = TRUE, size = 0.2, alpha = 0.4, stat = "density_ridges", panel_scaling=F) +
    theme_ridges() + 
    annotate(geom = 'text', label = annotationText, x = -Inf, y = Inf, hjust = 0, vjust = 1) +
    ylab('Density') +
    geom_vline(xintercept = cutpoints, linetype="dotted") +
    scale_x_continuous(labels=cutpoints, breaks=cutpoints, guide = guide_axis(check.overlap = T, angle = 90))
  return(plot)
}

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

# Receives the original data in long format and a list of metric names, and plots
# the metric distribution by using violin plots.
plot_metric_violins <- function(all, metric_names, output_folder){
  data = spread(all, Metric, Value)
  for (metric_name in metric_names){
    x = filter(all, Metric == metric_name)
    metric_values = x$Value %>% na.exclude()
    shapiro_p_value = format(shapiro.test(metric_values)$p.value, digits=4)
    ymax=max(metric_values) + (0.1 * max(metric_values))
    plot = ggplot(data = x, aes(x=Metric, y=Value)) + geom_violin() + geom_boxplot(width=0.2) + ylim(0, ymax) + labs(x = "") + annotate(geom = 'text', label = paste("Shapiro test p-value =", shapiro_p_value), size=3, x = -Inf, y = Inf, hjust = 0, vjust = 1)
    filename = paste0(metric_name, "_violin.pdf")
    ggsave(plot = plot, path = output_folder, filename = filename, width = 10, height = 15, units="cm", device='pdf', dpi=600)
  }
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

# Get arguments
setwd('/home/jredondo/tfm/production/')

#input="3-graphdb/4-output/ontoportal_bio_long_na.csv"
#output="4-evaluome/bio/salidaFran/"

#input="3-graphdb/4-output/ontoportal_agro_long_na.csv"
#output="4-evaluome/agro/salidaFran/"

#input="3-graphdb/4-output/ontoportal_biodiv_long_na.csv"
#output="4-evaluome/biodiv/salidaFran/"

#input="3-graphdb/4-output/ontoportal_earth_long_na.csv"
#output="4-evaluome/earth/salidaFran/"

#input="3-graphdb/4-output/ontoportal_eco_long_na.csv"
#output="4-evaluome/eco/salidaFran/"

#input="3-graphdb/4-output/ontoportal_ind_long_na.csv"
#output="4-evaluome/ind/salidaFran/"

# Get metrics file
all_long = read.csv2(input, header = T, sep = ",", na.strings = "NaN", stringsAsFactors = F)
colnames(all_long) = c('Ontology','Metric','Value')

all_long$Value = as.numeric(all_long$Value)
all_long$Ontology = as.character(all_long$Ontology)

all = spread(all_long, Metric, Value)
all$Ontology = tools::file_path_sans_ext(all$Ontology)

#Dataset without NAs
all = removeAllNA(all)

#install.packages("heatmaply")
#library(heatmaply)
#heatmaply::heatmaply_na(allWNNA)

# Remove columns with na
all = all[ , apply(all, 2, function(x) !any(is.na(x)))]

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
metric_ranges = getMetricRangeByCluster(all, k.range=k.range, bs=bs, seed=seed)

# Print evaluome plots
plots_path = file.path(output)
dir.create(path = plots_path)
for (i in 1:length(all_metrics)){
  metric_name = all_metrics[i]
  optimal_k = kOptTable %>% filter(Metric == all_metrics[i]) %>% pull(Global_optimal_k)
  plot = printDensityPlotWithPointsAndInfo(x, metric_name, optimal_k, stability_data, quality_data, metric_ranges)
  filename = paste0(metric_name, "_plot.pdf")
  ggsave(plot = plot, path = plots_path, filename = filename, width = 30, height = 10, units="cm", device='pdf', dpi=600)
}

# Print metric distribution plots
plot_metric_violins(all_long, all_metrics, plots_path)

# Print metrics correlation plot
row.names(all) = all$Ontology
all = all %>% select(-Ontology)
testRes = cor.mtest(all, conf.level = 0.95)
pdf(file = file.path(plots_path, "metrics_correlation.pdf"))
corrplot(cor(na.omit(all)), p.mat = testRes$p, sig.level = 0.05, is.cor=T, tl.col='black', type="full", order="hclust", hclust.method="ward.D",
         col=brewer.pal(n=8, name="RdYlGn"))
dev.off()
#ggsave(plot = plot, path = "/home/fabad/Descargas", filename = 'metric_correlation', width = 15, height = 15, units="cm", device='pdf', dpi=600)

all = read.csv2('3-graphdb/4-output/ontoportal_all_repositories.csv', header = T, sep = ",", na.strings = "NaN", stringsAsFactors = F)

sxc_agroportal = all %>% filter(repositorio == 'http://qc.um.es/ontoportal/agroportal' & metricName == 'synonyms per class metric') %>% pull(result) %>% as.numeric()
sxc_bioportal = all %>% filter(repositorio == 'http://qc.um.es/ontoportal/bioportal' & metricName == 'synonyms per class metric') %>% pull(result) %>% as.numeric()

summary(sxc_agroportal)
summary(sxc_bioportal)
wilcox.test(sxc_agroportal, sxc_bioportal)
