## annotate a list of SNPs

#ln -s /media/superdisk/reservebenefit/donnees/genomes/ genomes



## load an environment with bedtools vcftools available
SINGULARITY_SIMG="/media/superdisk/utils/conteneurs/snpsdata_analysis.simg"
singularity shell --bind /media/superdisk:/media/superdisk $SINGULARITY_SIMG

## global variables
### diplodus
GENOME_FASTA="genomes/sar_genome_lgt6000.fasta"
SPECIES="diplodus"
GFF3="/media/superdisk/reservebenefit/working/annotation/DSARv1_annotation.gff3"


## convert into bed
awk '{ print $1"\t"$2"\t"$2+1 }' selected_loci_diplodus.tsv > selected_loci_diplodus.bed

## get coding region for  SNPs
bedtools intersect -wb -a selected_loci_"$SPECIES".bed -b "$GFF3" > "$SPECIES"_coding.snps.bed
