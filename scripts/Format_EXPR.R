library(data.table)
library(R.utils)
library(stringr)

args <- commandArgs(trailingOnly = TRUE)
input_dir <- args[1]
output_dir <- args[2]
annot_dir <- args[3]

expr_list <- readRDS(file.path(input_dir, 'expr_list.rds'))
clin <- read.table(file.path(output_dir, 'CLIN.csv'), sep=';', header=TRUE)
sample_map <- clin[!is.na(clin$SRA.Run.ID..tumor.RNA), c('patient', 'SRA.Run.ID..tumor.RNA')]

for(assay_name in names(expr_list)){
  expr <- data.frame(expr_list[[assay_name]])
  expr <- expr[, colnames(expr) %in% sample_map$SRA.Run.ID..tumor.RNA]
  colnames(expr) <- unlist(lapply(colnames(expr), function(col){
    return(sample_map$patient[sample_map$SRA.Run.ID..tumor.RNA == col])
  }))
  write.table( 
    expr , 
    file= file.path(output_dir, paste0('EXPR_', str_replace(assay_name, 'expr_', ''), '.csv')) , 
    quote=FALSE , 
    sep=";" , 
    col.names=TRUE , 
    row.names=TRUE 
  )
}
