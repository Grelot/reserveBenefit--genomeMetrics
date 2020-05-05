
#SimRad
#Predictions in silico number of SNP with Simrad
#Lepais et al. 2014

library(Biostrings)
library(ShortRead)
library(SimRAD)
#Library biostrings-->require R 4.0.0
#protocole RAD
#1 enszyme:  Sbf1 restriction site (CCTGCAGG) in each genome
#This number, multiplied by two (because there is one RAD marker on both sides of each restriction site), is our expected number of RAD markers.
#Since we randomly picked one SNP per RAD marker this should be close to the number SNPs, but possibly higher since some RAD markers may not have SNPs.
#Such an estimation would be before/without filtering by physical distance (5kbp) to reduce linkage.
#If we want to compare our in silico estimate with our final empirical number of markers/SNPs, we would also need to also filter by physical distance in silico.



##SbfI
cs_5p1 <- "CCTGCA"
cs_3p1 <- "GG"

## diplodus Sargus
fasFile <- "./genome_insilico_digest/sar_genome_lgt6000.fasta"
## mullus Surmuletus
fasFile <- "./genome_insilico_digest/mullus_genome_lgt6000.fasta"
## serranus Cabrilla
fasFile <- "./genome_insilico_digest/serran_genome_lgt3000.fasta"


## in silico digest RAD single enzyme
genomFas <- ref.DNAseq(FASTA.file=fasFile, subselect.contigs =FALSE)
simseq.dig <- insilico.digest(genomFas, cs_5p1, cs_3p1, verbose=TRUE)
