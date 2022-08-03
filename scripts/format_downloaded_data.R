library(data.table)
library(readxl) 
library(stringr)

args <- commandArgs(trailingOnly = TRUE)
work_dir <- args[1]
annot_dir <- args[2]

# CLIN.txt
clin <- read_excel(file.path(work_dir, '1-s2.0-S009286741630215X-mmc1.xls'), sheet='S1A')
colnames(clin) <- clin[2, ]
clin <- clin[-c(1:2), ]
colnames(clin) <- str_replace_all(colnames(clin), '\\W', '.')
clin <- clin[str_detect(clin$Patient.ID, 'Pt'), ]
clin <- clin[!is.na(clin$Patient.ID), ]
clin[ clin == 'NA'] <- NA
clin[, c('Age', 'Overall.Survival', 'WES', 'RNAseq')] <- sapply(clin[, c('Age', 'Overall.Survival', 'WES', 'RNAseq')], as.numeric)
write.table(clin, file.path(work_dir, "CLIN.txt"), sep="\t" , col.names=TRUE, row.names=FALSE)

# EXPR_gene_tpm.tsv, EXPR_gene_counts.tsv, EXPR_tx_tpm.tsv, EXPR_tx_counts.tsv
source('https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/process_kallisto_output.R')
load(file.path(annot_dir, "Gencode.v40.annotation.RData"))
process_kallisto_output(work_dir, 'Hugo_kallisto.zip', tx2gene)