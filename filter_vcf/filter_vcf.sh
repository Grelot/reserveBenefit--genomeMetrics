## container
SINGULARITY_SIMG="/media/superdisk/utils/conteneurs/snpsdata_analysis.simg"

## singularity exec command
#SINGULARITY_EXEC_CMD="singularity exec --bind /media/superdisk:/media/superdisk"
#vcftools=${SINGULARITY_EXEC_CMD}" "${SINGULARITY_SIMG}" vcftools"

## load an environment with bedtools vcftools available
singularity shell --bind /media/superdisk:/media/superdisk $SINGULARITY_SIMG


## diplodus
VCF_INIT="/media/superdisk/reservebenefit/working/rerun1/snakemake_stacks2/06-populations/iter3/diplodus/populations.snps.vcf"

## mullus
VCF_INIT="/media/superdisk/reservebenefit/working/rerun1/snakemake_stacks2/06-populations/iter4/mullus/populations.snps.vcf"


## serranus
VCF_INIT="/media/superdisk/reservebenefit/working/rerun1/snakemake_stacks2/06-populations/iter2/serran/populations.snps.vcf"



## coverage per individuals
vcftools --vcf "${VCF_INIT}" --depth 

vcftools --vcf "${VCF_INIT}" --missing-indv

vcftools --vcf "${VCF_INIT}" --missing-site
