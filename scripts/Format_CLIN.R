args <- commandArgs(trailingOnly = TRUE)
input_dir <- args[1]
output_dir <- args[2]

source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/Get_Response.R")

clin = read.csv( file.path(input_dir, "CLIN.txt"), stringsAsFactors=FALSE , sep="\t" , dec=',')

clin = cbind( clin[ , c( "Patient.ID","irRECIST","Gender","Age","Overall.Survival","Vital.Status" ) ] , "PD-1/PD-L1" , "Melanoma" , NA , NA , NA , NA , NA , NA , NA , NA )
colnames(clin) = c( "patient" , "recist" , "sex"  ,"age"  , "t.os" , "os" , "drug_type" , "primary" , "response.other.info" , "response" , "histo" , "stage" , "t.pfs" , "pfs" , "dna" , "rna")

clin$t.os = clin$t.os / 30.5
clin$os = ifelse(clin$os %in% "Dead" , 1 , 0 )
clin$recist = ifelse(clin$recist %in% "Complete Response" , "CR" ,
				ifelse(clin$recist %in% "Partial Response" , "PR" ,
				ifelse(clin$recist %in% "Progressive Disease" , "PD" , NA )))

clin$response = Get_Response( data=clin )


case = read.csv( file.path(output_dir, "cased_sequenced.csv"), stringsAsFactors=FALSE , sep=";" )
clin$rna[ clin$patient %in% case[ case$expr %in% 1 , ]$patient ] = "fpkm"
clin$dna[ clin$patient %in% case[ case$cna %in% 1 , ]$patient ] = "wes"

clin = clin[ , c("patient" , "sex" , "age" , "primary" , "histo" , "stage" , "response.other.info" , "recist" , "response" , "drug_type" , "dna" , "rna" , "t.pfs" , "pfs" , "t.os" , "os" ) ]

write.table( clin , file=file.path(output_dir, "CLIN.csv") , quote=FALSE , sep=";" , col.names=TRUE , row.names=FALSE )

