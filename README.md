<a href="https://www.biodiversa.org/1023"><img align="right" width="100" height="100" src="reservebenefit.jpg"></a>

# Codes for the paper : "Genomic resources for Mediterranean fishes"

[![https://www.singularity-hub.org/static/img/hosted-singularity--hub-%23e32929.svg](https://www.singularity-hub.org/static/img/hosted-singularity--hub-%23e32929.svg)](https://singularity-hub.org/collections/3566)

_______________________________________________________________________________



#### Pierre-Edouard Guerin, Stephanie Manel

Montpellier, 2017-2019

Submited to Molecular Ecology Ressources, 2019


_______________________________________________________________________________

# Prerequisites

## Softwares

- [R Version 3.6.0](https://cran.r-project.org/)
	* R packages: ggplot2, plyr, reshape, gridExtra

- [faidx](http://www.htslib.org/doc/faidx.html)

- [bedtools](https://bedtools.readthedocs.io/en/latest/)

- [vcftools](http://vcftools.sourceforge.net/)

- [samtools](http://www.htslib.org/download/)

- [htslib](http://www.htslib.org/download/)

- [bcftools](http://www.htslib.org/download/)



## Singularity container

See https://www.sylabs.io/docs/ for instructions to install Singularity.

#### Download the container

```
singularity pull --name snpsdata_analysis.simg shub://Grelot/reserveBenefit--snpsdata_analysis:snpsdata_analysis
```

#### Run the container

```
singularity run snpsdata_analysis.simg
```

_______________________________________________________________________________


# Data files

We work on three species : _mullus surmuletus_, _diplodus sargus_ and _serranus cabrilla_.
Let's define the wildcard `species` as any of these three species.

* genome assembly `.fasta`

* SNPs data from radseq `.vcf`

# Filtering SNPs

Only one randomly selected SNP was retained per locus, and a locus was retained only if present in at least 85% of individuals. Individuals with an excess coverage depth (>1,000,000x) or >30% missing data were filtered out. We kept loci with maximum observed heterozygosity=0.6.

#### Filtering steps (IBD paper)
1. Remove loci with inbreeding coefficient _Fis_ > 0.5 or < -0.5
2. Keep all pairs of loci that are closer than 5000 bp
3. Keep pairs of loci with linkage desequilibrum _r²_ > 0.8
4. Keep SNPs with a minimum minor allele frequency (MAF) of 1%
5. Remove loci that deviated significantly (p-value <0.01) from expected Hardy-Weinberg genotyping frequencies under random mating


#### Filtering steps (genome paper)
1. Keep all pairs of loci that are closer than 5000 bp
2. Keep pairs of loci with linkage desequilibrum _r²_ > 0.8
3. Keep SNPs with a minimum minor allele frequency (MAF) of 1%


#### INPUTS:

* `species`.vcf: SNPs from radseq data of `species` 
* `species`.sumstats.tsv: [Summary statistics for each population](http://catchenlab.life.illinois.edu/stacks/manual-v1/#pfiles)


#### OUTPUTS: 

* `species`.lmiss: number of missing individuals by locus table
* `species`.imiss: number of missing loci by individual table
* `species`.idepth: mean locus depth coverage by individual table
* `species`.geno.ld: linkage desequilibrum _r² table
* `species`.snps.fisloc_rm.vcf
* `species`.fisloc_rm.ld_5000.log        
* `species`.fisloc_rm.ld_5000.recode.vcf  
* `species`.fisloc_rm.ld_5000.r2.recode.vcf                 
* `species`.fisloc_rm.ld_5000.r2.maf001.recode.vcf
* `species`.fisloc_rm.ld_5000.r2.maf001.hwe.recode.vcf: final filtered snps
* `species`filtering_count_snps_report.tsv: number of SNPs at each filtering step


```
cd filter_vcf
bash filter_vcf.sh
```

# Description of SNPs onto genome

#### Generate tables

1. Split the genome into genome-windows of 400 Kbp.
2. Count number of SNPs located on each genome-windows.
3. Count number of reads for each SNP for each individuals.

#### INPUTS:
* `species`.fasta: genome fasta file of `species`
* `species`.vcf: SNPs from radseq data of `species`
* `species`.gff3: coordinates and related information of coding region annotation genome of `species`

#### OUTPUTS: 
* `species`coverage.bed: a table with row as genome-windows of 400000bp of the genome of `species` with genome-coordinates (scaffold, start position, end position) and coverage (number of SNPs)
* `species`meandepth.bed: a table with row as SNPs with genome-windows, coordinates (scaffold, start position, end position) and depth coverage (number of reads) for each SNP for each individuals
* `species`coords.snps.bed: coordinates (scaffold, position) of SNPs onto genomes
* `species`coding.snps.bed: snps located on coding region


```
bash snpsontothegenome/command.sh
```

#### Build the figure

```
Rscript snpsontothegenome/figure_cover_genome.R
```

# Average distance between SNPs loci

#### INPUTS:
* `species`coords.snps.bed : coordinates (scaffold, position) of SNPs onto genomes


```
Rscript snpsontothegenome/average_distance_loci.R
```

# SNPs located/not in coding regions

Simply count number of lines of the file `species`coding.snps.bed (each line is a snp located on a coding region)


# SNPs located/not in mitochondrial regions

............


# Results

* [distance_loci.csv](results/distance_loci.csv) : mean, median and sd distance between consecutive loci


species |  mean            | median|   sd             | max     | min
---------|------------------|-------|------------------|---------|----
diplodus | 35388.9078430345 | 23751 | 34996.9143024498 | 459616  |5000
mullus   | 30716.8684498214 | 20930 | 29189.8335674228 | 384550  |5002
serran   | 28239.7585528699 | 19084 | 27013.2843728281 | 403508  |733




* [summary_snps.csv](results/summary_snps.csv): number of SNPs, average distance between consecutive loci (in bp) and number of SNPs located on a coding region for each `species`

species   |   number_snps  |   average_distance_bp   |   number_coding_snps
----------|----------------|-------------------------|---------------------
diplodus  |   20074        |   35389                 |   11978
mullus    |   15710        |   30717                 |   10304
serranus  |   21101        |   28240                 |   13107



