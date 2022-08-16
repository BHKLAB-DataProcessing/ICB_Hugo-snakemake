library(tibble)

args <- commandArgs(trailingOnly = TRUE)
input_dir <- args[1]
output_dir <- args[2]
annot_dir <- args[3]

source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/Get_Response.R")
source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/format_clin_data.R")
source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/annotate_tissue.R")
source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/annotate_drug.R")

clin_original = read.csv( file.path(input_dir, "CLIN.txt"), stringsAsFactors=FALSE , sep="\t" , dec=',')
selected_cols <- c( "Patient.ID","irRECIST","Gender","Age","Overall.Survival","Vital.Status" )
clin = cbind( clin_original[ , selected_cols] , "PD-1/PD-L1" , "Melanoma" , NA , NA , NA , NA , NA , NA , NA , NA )
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

clin = format_clin_data(clin_original, 'Patient.ID', selected_cols, clin)

# Tissue and drug annotation
annotation_tissue <- read.csv(file=file.path(annot_dir, 'curation_tissue.csv'))
clin <- annotate_tissue(clin=clin, study='Hugo', annotation_tissue=annotation_tissue, check_histo=FALSE)

annotation_drug <- read.csv(file=file.path(annot_dir, 'curation_drug.csv'))
clin <- add_column(clin, treatmentid=annotate_drug('Hugo', clin$Treatment, annotation_drug), .after='tissueid')

write.table( clin , file=file.path(output_dir, "CLIN.csv") , quote=FALSE , sep=";" , col.names=TRUE , row.names=FALSE )

