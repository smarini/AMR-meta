library(Matrix)
library(stringr)
library(glmnet)

#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

progdir = args[1] # base directory
in_file = args[2]  # index of the feature file
outdir = args[3]  # output directory

sparse_features = scan(in_file, sep = '\n', what = 'integer')  # read indeces of 1s to build sparse binary matrix

get_coordinates <- function(x) {  # function to convert indeces in the right format x,y
  tmp = as.numeric(unlist(str_split(x, ',')))
  cbind(rep(tmp[1],length(tmp)-2),
        tmp[2:(length(tmp)-1)])
}

k = do.call(rbind, sapply(sparse_features[1:(length(sparse_features)-1)], get_coordinates)) # convert indeces in the right format x,y 

kmer_data=sparseMatrix(x = TRUE, i=k[,1], j=k[,2])

if(dim(kmer_data)[2] < 138260){ # if some kmers are not present in the data set, add corresponding columns
  add_zeros=Matrix(FALSE, ncol=138260-dim(kmer_data)[2], nrow=dim(kmer_data)[1], sparse=TRUE)
  kmer_data=cbind(kmer_data,add_zeros)
}

tot_samples = as.numeric(sparse_features[length(sparse_features)])  # last line in the index file is the total number of samples

if(dim(kmer_data)[1] < tot_samples){  # if last samples do not have any kmer, add empty lines
  add_zeros=Matrix(FALSE, ncol=138260, nrow=tot_samples-dim(kmer_data)[1], sparse=TRUE)
  kmer_data=rbind(kmer_data,add_zeros)
}

# Preparing metafetures matrix
metaf_matrix = readRDS(paste0(progdir, '/data/metaf.matrix.rds'))
metaf_data = kmer_data %*% metaf_matrix

classes = c("Aminoglycosides",
            "betalactams",
            "Drug_and_biocide_resistance",
            "Fluoroquinolones",
            "Glycopeptides",
            "Lipopeptides",
            "MLS",
            "Multi-biocide_resistance",
            "Multi-drug_resistance",
            "Multi-metal_resistance",
            "Phenicol",
            "Sulfonamides",
            "Tetracyclines")

# Predicting AMR classes

predictions_kmer = predictions_metaf = NULL
for (i in 1:length(classes)){
  cv.fit.lasso = readRDS(paste0(progdir, '/models/', classes[i], '.lasso.kmer.model.rds'))
  cv.fit.ridge = readRDS(paste0(progdir, '/models/', classes[i], '.ridge.metaf.model.rds'))
  predictions_kmer = cbind(predictions_kmer, predict(cv.fit.lasso, newx = kmer_data, type="response"))
  predictions_metaf = cbind(predictions_metaf, predict(cv.fit.ridge, newx = metaf_data, type="response"))
}
colnames(predictions_kmer) = classes

message(in_file)
in_file = str_split(in_file, '_')[[1]][3]
write.table(predictions_kmer, file = paste0(outdir, '/kmer_predictions_', in_file), sep = ',', quote = FALSE, row.names = FALSE)
write.table(predictions_metaf, file = paste0(outdir, '/metaf.predictions_', in_file), sep = ',', quote = FALSE, row.names = FALSE)
