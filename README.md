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


# Mapping SNPs onto genome

#### Generate tables

1. Split the genome into genome-windows of 400000bp.
2. Count number of SNPs located on each genome-windows.
3. Count number of reads for each SNP for each individuals.

INPUTS:
* `species`.fasta: genome fasta file of `species`
* `species`.vcf: SNPs from radseq data of `species`
* `species`.gff3: coordinates and related information of coding region annotation genome of `species`

OUTPUTS: 
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

INPUTS:
* `species`coords.snps.bed : coordinates (scaffold, position) of SNPs onto genomes


```
Rscript snpsontothegenome/average_distance_loci.R
```

# SNPs located/not in coding regions

Simply count number of lines of the file `species`coding.snps.bed (each line is a snp located on a coding region)


# SNPs located/not in mitochondrial regions

............


# Results

* [summary_snps.csv](results/summary_snps.csv): number of SNPs, average distance between consecutive loci (in bp) and number of SNPs located on a coding region for each `species`

species   |   number_snps  |   average_distance_bp   |   number_coding_snps
----------|----------------|-------------------------|---------------------
diplodus  |   39678        |   17552                 |   24644
mullus    |  31009         |   14744                 |  21054
serranus  |   47954        |   11912                 |   30617
