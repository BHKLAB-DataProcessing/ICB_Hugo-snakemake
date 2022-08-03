from snakemake.remote.S3 import RemoteProvider as S3RemoteProvider
S3 = S3RemoteProvider(
    access_key_id=config["key"], 
    secret_access_key=config["secret"],
    host=config["host"],
    stay_on_remote=False
)
prefix = config["prefix"]
filename = config["filename"]

rule get_MultiAssayExp:
    input:
        S3.remote(prefix + "processed/CLIN.csv"),
        S3.remote(prefix + "processed/EXPR_gene_tpm.csv"),
        S3.remote(prefix + "processed/EXPR_gene_counts.csv"),
        S3.remote(prefix + "processed/EXPR_isoform_tpm.csv"),
        S3.remote(prefix + "processed/EXPR_isoform_counts.csv"),
        # S3.remote(prefix + "processed/SNV.csv"),
        S3.remote(prefix + "processed/cased_sequenced.csv"),
        S3.remote(prefix + "annotation/Gencode.v40.annotation.RData")
    output:
        S3.remote(prefix + filename)
    shell:
        """
        Rscript -e \
        '
        load(paste0("{prefix}", "annotation/Gencode.v40.annotation.RData"))
        source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/get_MultiAssayExp.R");
        saveRDS(
            get_MultiAssayExp(study = "Hugo", input_dir = paste0("{prefix}", "processed"), expr_with_counts_isoforms=TRUE), 
            "{prefix}{filename}"
        );
        '
        """

rule format_expr:
    input:
        S3.remote(prefix + "download/expr_list.rds"),
        S3.remote(prefix + "processed/CLIN.csv")
    output:
        S3.remote(prefix + "processed/EXPR_gene_tpm.csv"),
        S3.remote(prefix + "processed/EXPR_gene_counts.csv"),
        S3.remote(prefix + "processed/EXPR_isoform_tpm.csv"),
        S3.remote(prefix + "processed/EXPR_isoform_counts.csv"),
        S3.remote(prefix + "processed/CLIN.csv")
    shell:
        """
        Rscript scripts/Format_EXPR.R \
        {prefix}download \
        {prefix}processed \
        """

rule format_clin:
    input:
        S3.remote(prefix + "processed/cased_sequenced.csv"),
        S3.remote(prefix + "download/CLIN.txt")
    output:
        S3.remote(prefix + "processed/CLIN.csv")
    shell:
        """
        Rscript scripts/Format_CLIN.R \
        {prefix}download \
        {prefix}processed \
        """

# rule format_snv:
#     output:
#         S3.remote(prefix + "processed/SNV.csv")
#     input:
#         S3.remote(prefix + "download/SNV.txt.gz"),
#         S3.remote(prefix + "processed/cased_sequenced.csv")
#     shell:
#         """
#         Rscript scripts/Format_SNV.R \
#         {prefix}download \
#         {prefix}processed \
#         """

rule format_cased_sequenced:
    input:
        S3.remote(prefix + "download/CLIN.txt")
    output:
        S3.remote(prefix + "processed/cased_sequenced.csv")
    shell:
        """
        Rscript scripts/Format_cased_sequenced.R \
        {prefix}download \
        {prefix}processed \
        """

rule format_downloaded_data:
    input:
        S3.remote(prefix + "download/1-s2.0-S009286741630215X-mmc1.xls"),
        S3.remote(prefix + "download/Hugo_kallisto.zip"),
        S3.remote(prefix + "annotation/Gencode.v40.annotation.RData")
    output:
        S3.remote(prefix + "download/CLIN.txt"),
        S3.remote(prefix + "download/expr_list.rds")
    shell:
        """
        Rscript scripts/format_downloaded_data.R \
        {prefix}download \
        {prefix}annotation        
        """

rule download_annotation:
    output:
        S3.remote(prefix + "annotation/Gencode.v40.annotation.RData")
    shell:
        """
        wget https://github.com/BHKLAB-Pachyderm/Annotations/blob/master/Gencode.v40.annotation.RData?raw=true -O {prefix}annotation/Gencode.v40.annotation.RData 
        """

rule download_data:
    output:
        S3.remote(prefix + "download/1-s2.0-S009286741630215X-mmc1.xls"),
        S3.remote(prefix + "download/Hugo_kallisto.zip")
    shell:
        """
        wget https://ars.els-cdn.com/content/image/1-s2.0-S009286741630215X-mmc1.xls -O {prefix}download/1-s2.0-S009286741630215X-mmc1.xls
        wget https://github.com/BHKLAB-Pachyderm/ICB_Hugo-data/raw/main/Hugo_kallisto.zip -O {prefix}download/Hugo_kallisto.zip
        """ 