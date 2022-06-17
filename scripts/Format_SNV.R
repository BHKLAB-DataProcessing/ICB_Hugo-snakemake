library(data.table)
library(R.utils)

args <- commandArgs(trailingOnly = TRUE)
input_dir <- args[1]
output_dir <- args[2]

snv = as.data.frame( fread( file.path(input_dir, "SNV.txt.gz") , sep="\t" , stringsAsFactors=FALSE  ))

data = cbind( snv[ , c("Pos" , "Sample" , "Gene", "MutType" ) ] ,
				snv[ , "Chr" ] ,
				t( sapply( snv[ , "NucMut" ] , function(x){ matrix( unlist( strsplit( x , ">" , fixed = TRUE ) ) ) } ) ) )

colnames(data) = c( "Pos" , "Sample" , "Gene" , "Effect" , "Chr" , "Ref" , "Alt" )
data$Ref = ifelse( data$Ref %in% "-" , "" , data$Ref )
data$Alt = ifelse( data$Alt %in% "-" , "" , data$Alt )


data = cbind( data , apply( data[ , c("Ref" , "Alt") ] , 1 , function(x){ ifelse( nchar(x[1]) != nchar(x[2]) , "INDEL", "SNV") } ) )

colnames(data) = c( "Pos" , "Sample" , "Gene" , "Effect" , "Chr" , "Ref" , "Alt" , "MutType" )

data = data[ , c( "Sample" , "Gene" , "Chr" , "Pos" , "Ref" , "Alt" , "Effect" , "MutType" ) ]


case = read.csv( file.path(output_dir, "cased_sequenced.csv"), stringsAsFactors=FALSE , sep=";" )
data = data[ data$Sample %in% case[ case$snv %in% 1 , ]$patient , c( "Sample" , "Gene" , "Chr" , "Pos" , "Ref" , "Alt" , "Effect" , "MutType" ) ]

write.table( data , file=file.path(output_dir, "SNV.csv") , quote=FALSE , sep=";" , col.names=TRUE , row.names=FALSE )
