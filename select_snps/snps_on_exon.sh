SINGULARITY_SIMG=snpsdata_analysis.simg
singularity shell $SINGULARITY_SIMG
GENOME_FASTA="genomes/sar_genome_lgt6000.fasta"


## select SNPs on an exon
bedtools intersect -wb -a select_snps/vcf/18512snps-276ind_diplodus.vcf -b select_snps/annotation/DSARv1_annotation.gff3 | grep "exon" | rev | cut -f10- | rev | uniq > select_snps/diplodus_sargus_exon.protovcf
cat <(head -15 select_snps/vcf/18512snps-276ind_diplodus.vcf) select_snps/diplodus_sargus_exon.protovcf > select_snps/diplodus_sargus_exon.vcf