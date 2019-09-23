# ordered list of names of scaffold and their sizes for the genome
faidx 08-genomes/mullus_genome.fasta -i chromsizes | sort -nrk2 > 07-post/mullus_chromsizes.tsv
## names of scaffolds greater than 100.000 pb
##...plus tard je teste sur un seul scaffold dabord
## scaffold382_cov192
#cd 07-post/
## vcf with only the scaffold382_cov192
#vcftools --chr scaffold382_cov192 --vcf 06-populations/iter2/mullus/populations.snps.vcf --out 07-post/mullus_scaffold382_cov192 --recode
## 
### vcf with only scaffold greater than 80000 bp
COMMAND="vcftools --vcf 06-populations/iter2/mullus/populations.snps.vcf --out 07-post/mullus_big_scaffolds --recode"
for sca in `awk '{ if($2 > 80000) print $1}' 07-post/mullus_chromsizes.tsv`
do 
	COMMAND=$COMMAND" --chr "$sca
done
echo $COMMAND | bash
## convert vcf into tsv files with scaffold and position as colon
vcf2bed < 07-post/mullus_big_scaffolds.recode.vcf | awk '{ print $1"\t"$2}' > 07-post/mullus_big_scaffolds_snps_pos.tsv
## get distances between pair of SNPS on the same scaffold
Rscript distance_between_SNPS_pair.R

#vcf2bed < 07-post/mullus_scaffold382_cov192.recode.vcf | awk '{ print $1"\t"$2}' > 07-post/mullus_scaffold382_cov192_snps_pos.tsv
#vcf2bed < 06-populations/iter2/mullus/populations.snps.vcf | awk '{ print $1"\t"$2}' > 07-post/mullus_snps_pos.tsv
