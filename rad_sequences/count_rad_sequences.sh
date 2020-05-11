
## load an environment with bedtools vcftools available
SINGULARITY_SIMG="/media/superdisk/utils/conteneurs/snpsdata_analysis.simg"
singularity shell --bind /media/superdisk:/media/superdisk $SINGULARITY_SIMG

# cd /media/superdisk/reservebenefit/working/rerun1/analysis/rad_sequence_count

### diplodus
CATALOG="/media/superdisk/reservebenefit/working/rerun1/snakemake_stacks2/05-stacks/iter3/diplodus/catalog.fa.gz"
SPECIES="diplodus"
### mullus
CATALOG="/media/superdisk/reservebenefit/working/rerun1/snakemake_stacks2/05-stacks/iter4/mullus/catalog.fa.gz"
SPECIES="mullus"
### serranus
CATALOG="/media/superdisk/reservebenefit/working/rerun1/snakemake_stacks2/05-stacks/iter2/serran/catalog.fa.gz"
SPECIES="serranus"

## convert catalog.fa.gz into bed
zcat $CATALOG | grep "^>" | awk '{ print $2}' | cut -d ':' -f 1-2 | cut -d '=' -f 2 | awk -F ':' '{ print $1"\t"$2"\t"$2+10 }' > "$SPECIES".loci.bed
## merge loci 
bedtools merge -i "$SPECIES".loci.bed -d 1600 -c 1 -o count | awk '{ if($4 >1) print $0 }' > "$SPECIES".merge.bed



## count number of unique sequence rad
echo "species,count_unique_rad_sequence" > total_count_rad.csv
for spe in diplodus mullus serranus; do COUNT_SEQ=`cat "$spe".merge.bed | wc -l` ; echo $spe","$COUNT_SEQ ; done >> total_count_rad.csv