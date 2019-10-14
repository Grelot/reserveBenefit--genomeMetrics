## container
SINGULARITY_SIMG="/media/superdisk/utils/conteneurs/snpsdata_analysis.simg"

## singularity exec command
#SINGULARITY_EXEC_CMD="singularity exec --bind /media/superdisk:/media/superdisk"
#vcftools=${SINGULARITY_EXEC_CMD}" "${SINGULARITY_SIMG}" vcftools"

## load an environment with bedtools vcftools available
singularity shell --bind /media/superdisk:/media/superdisk $SINGULARITY_SIMG

###############################################################################
##function



filtering_snps () {

## set local variables
SPECIES=$1
VCF_INIT=$2
POP_SUMSTATS=$3


## coverage per individuals
vcftools --vcf "${VCF_INIT}" --depth --out "${SPECIES}"
vcftools --vcf "${VCF_INIT}" --missing-indv --out "${SPECIES}"
vcftools --vcf "${VCF_INIT}" --missing-site --out "${SPECIES}"


## fisLoc_removed (Fis info is contained in POP_SUMSTATS)
VCF_RM_FIS="${SPECIES}".snps.fisloc_rm.vcf
perl filter_fis.pl $POP_SUMSTATS $VCF_INIT > "${VCF_RM_FIS}"

## linkage desequilibrium - detect and remove loci in LD

## remove loci closer than certain distance apart : closer than 5000bp together
OUT_RM_FIS_LD="${SPECIES}".fisloc_rm.ld_5000
VCF_RM_FIS_LD="${OUT_RM_FIS_LD}".recode.vcf
vcftools \
  --vcf "${VCF_RM_FIS}" \
  --thin 5000 \
  --out "${OUT_RM_FIS_LD}" \
  --recode

## remove loci with LD R2 > 0,8
OUT_GENO_LD="${SPECIES}".geno.ld
vcftools \
  --vcf "${VCF_RM_FIS_LD}" \
  --geno-r2
  --out "${SPECIES}"
VCF_RM_FIS_LD_RD="${SPECIES}".fisloc_rm.ld_5000.r2.recode.vcf
perl filter_LDr2.pl "${OUT_GENO_LD}" "${VCF_RM_FIS_LD}" > "${VCF_RM_FIS_LD_RD}"

### min MAF 0.01
OUT_RM_FIS_LD_RD_MAF="${SPECIES}".fisloc_rm.ld_5000.r2.maf001
VCF_RM_FIS_LD_RD_MAF="${SPECIES}".fisloc_rm.ld_5000.r2.maf001.recode.vcf
vcftools \
  --vcf "${VCF_RM_FIS_LD_RD}" \
  --maf 0.01 \
  --out "${OUT_RM_FIS_LD_RD_MAF}" \
  --recode

## filter out loci that are not in HWE (from MAF 0.01 filtering)
OUT_RM_FIS_LD_RD_MAF_HWE="${SPECIES}".fisloc_rm.ld_5000.r2.maf001.hwe
VCF_RM_FIS_LD_RD_MAF_HWE="${OUT_RM_FIS_LD_RD_MAF_HWE}".recode.vcf
vcftools \
  --vcf "${VCF_RM_FIS_LD_RD_MAF}" \
  --hwe 0.01 \
  --out "${OUT_RM_FIS_LD_RD_MAF_HWE}" \
  --recode


## number of snps at each filtering step
grep -c -v "^#" $VCF_INIT \
$VCF_RM_FIS \
$VCF_RM_FIS \
$VCF_RM_FIS_LD \
$VCF_RM_FIS_LD_RD \
$VCF_RM_FIS_LD_RD_MAF \
$VCF_RM_FIS_LD_RD_MAF_HWE \
| while read LINE; do
	echo $LINE | tr ":" "\t" ;done > "${SPECIES}"_filtering_count_snps_report.tsv


}



###############################################################################

## diplodus
SPECIES="diplodus"
VCF_INIT="/media/superdisk/reservebenefit/working/rerun1/snakemake_stacks2/06-populations/iter3/diplodus/populations.snps.vcf"
POP_SUMSTATS="/media/superdisk/reservebenefit/working/rerun1/snakemake_stacks2/06-populations/iter3/diplodus/populations.sumstats.tsv"
filtering_snps $SPECIES $VCF_INIT $POP_SUMSTATS


## mullus
SPECIES="mullus"
VCF_INIT="/media/superdisk/reservebenefit/working/rerun1/snakemake_stacks2/06-populations/iter4/mullus/populations.snps.vcf"
POP_SUMSTATS="/media/superdisk/reservebenefit/working/rerun1/snakemake_stacks2/06-populations/iter4/mullus/populations.sumstats.tsv"
filtering_snps $SPECIES $VCF_INIT $POP_SUMSTATS


## serranus
SPECIES="serran"
VCF_INIT="/media/superdisk/reservebenefit/working/rerun1/snakemake_stacks2/06-populations/iter2/serran/populations.snps.vcf"
POP_SUMSTATS="/media/superdisk/reservebenefit/working/rerun1/snakemake_stacks2/06-populations/iter2/serran/populations.sumstats.tsv"
filtering_snps $SPECIES $VCF_INIT $POP_SUMSTATS


