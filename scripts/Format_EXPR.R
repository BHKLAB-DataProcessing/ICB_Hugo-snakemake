library(data.table)
library(R.utils)

args <- commandArgs(trailingOnly = TRUE)
input_dir <- args[1]
output_dir <- args[2]

expr = as.data.frame( fread( file.path(input_dir, "EXPR.txt.gz")  , sep="\t" , dec="," , stringsAsFactors=FALSE ))
rownames(expr)  = expr[,1] 
expr = expr[,-1]
colnames(expr)  = sapply( colnames(expr) , function(x){  unlist( strsplit( as.character( x ) , "." , fixed=TRUE ) )[1] } )
colnames(expr)[grep("Pt27A",colnames(expr))] = "Pt27"

case = read.csv( file.path(output_dir, "cased_sequenced.csv"), stringsAsFactors=FALSE , sep=";" )
expr = log2( expr[ , colnames(expr) %in% case[ case$expr %in% 1 , ]$patient ] + 1 )

write.table( expr , file= file.path(output_dir, "EXPR.csv") , quote=FALSE , sep=";" , col.names=TRUE , row.names=TRUE )