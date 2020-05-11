## count number of CDS, exon, gene, intron

## load an environment with bedtools vcftools available
SINGULARITY_SIMG="/media/superdisk/utils/conteneurs/snpsdata_analysis.simg"
singularity shell --bind /media/superdisk:/media/superdisk $SINGULARITY_SIMG

## get coding region for SNPs
### diplodus
GFF3="/media/superdisk/reservebenefit/working/annotation/DSARv1_annotation.gff3"
SPECIES="diplodus"
bedtools intersect -wb -a "$SPECIES"_coords.snps.bed -b "$GFF3" > "$SPECIES"_gff3.snps.bed
### mullus
GFF3="/media/superdisk/reservebenefit/working/annotation/MSURv1_annotation.gff3"
SPECIES="mullus"
bedtools intersect -wb -a "$SPECIES"_coords.snps.bed -b "$GFF3" > "$SPECIES"_gff3.snps.bed
### serran
GFF3="/media/superdisk/reservebenefit/working/annotation/SCABv1_annotation.gff3"
SPECIES="serran"
bedtools intersect -wb -a "$SPECIES"_coords.snps.bed -b "$GFF3" > "$SPECIES"_gff3.snps.bed

## count number of CDS, exon, gene, intron
echo "species,raw,gene,exon,intron,cds" > total.count.snps.detail_annotation.csv
for SPECIES in diplodus mullus serran;
do
NB_SNPS=`wc -l "$SPECIES"_coords.snps.bed`
NB_CDS=`awk '{ if($6 == "CDS") print $0 }' "$SPECIES"_gff3.snps.bed | wc -l`
NB_EXON=`awk '{ if($6 == "exon") print $0 }' "$SPECIES"_gff3.snps.bed | wc -l`
NB_GENE=`awk '{ if($6 == "gene") print $0 }' "$SPECIES"_gff3.snps.bed | wc -l`
NB_INTRON=$(($NB_GENE-$NB_EXON))
echo $SPECIES","$NB_SNPS","$NB_GENE","$NB_EXON","$NB_INTRON","$NB_CDS
done >> total.count.snps.detail_annotation.csv

