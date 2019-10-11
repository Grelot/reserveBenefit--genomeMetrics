# *~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~
# *~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~
# *~*~*~										     ~*~*~*~
# *~*~*~    RAD Seq Data RESERVEBENEFIT 	     ~*~*~*~
# *~*~*~	Author: Katharina Fietz				 ~*~*~*~
# *~*~*~	March 8th 2019					 	 	 ~*~*~*~
# *~*~*~										     ~*~*~*~
# *~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~
# *~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~


# ------------------------------------------------------------




###COPY ALL     DIPLODUS      DATA FROM PIERRE'S SERVER TO MINE.
#GSTACKS output without Fis outlier individuals:
scp kfietz@162.38.198.29:/media/superdisk/reservebenefit/working/rerun1/snakemake_stacks2/05-stacks/iter3/diplodus/* $WORK/Pierre/stacks2.2/DIPLODUS_iter3/05-gstacks


# ------------------------------------------------------------


###POPULATIONS

#run POPULATIONS again with min_maf=0.01 (use "pop_diplodus2.sh") on output from gstacks diplodus_iter3.

#  1.    CHANGE qsub Verzeichnis in "pop_diplodus2.sh" to $WORK/Pierre/stacks2.2/DIPLODUS_iter3/06-populations
#  2.    COPY "pop_diplodus2.sh" to $WORK/Pierre/stacks2.2/DIPLODUS_iter3/00-scripts
#		  sed command on script
#  3.    ADJUST pop_map and take out 17 outlier inds.
#  4.	  RUN AGAIN populations with diplodus_iter3 data and new "pop_diplodus2.sh" script.


#prepare populations scripts:
cd 
sed -i -e 's/\r$//' $WORK/Pierre/stacks2.2/DIPLODUS_iter3/00-scripts/pop_diplodus2.sh
cd $WORK/Pierre/stacks2.2/DIPLODUS_iter3/06-populations
qsub $WORK/Pierre/stacks2.2/DIPLODUS_iter3/00-scripts/pop_diplodus2.sh

#count loci:
grep  -c -v "^#" $WORK/Pierre/stacks2.2/DIPLODUS_iter3/06-populations/populations.snps.vcf
#  47588 loci

# ------------------------------------------------------------


###COVERAGE PER INDIVIDUAL
cd $WORK/Pierre/stacks2.2/DIPLODUS_iter3/06-populations
vcftools --vcf populations.snps.vcf --depth 

#  ..... loci still present here
#	-->  output file "out.idepth"
# Sup Mat "Coverage"


# ------------------------------------------------------------


###MISSING DATA
screen
cd $WORK/Pierre/stacks2.2/DIPLODUS_iter3/06-populations
vcftools --vcf populations.snps.vcf --missing-indv
vcftools --vcf populations.snps.vcf --missing-site
#	--> output file "out.imiss"  -  plot in Excel
# Sup Mat "missingData_ind"
# Remove ind with >30% missing data (none)


# ------------------------------------------------------------


###INBREEDING COEFFICIENT FIS


##PER INDIVIDUAL
cd $WORK/Pierre/stacks2.2/DIPLODUS_iter3/06-populations
vcftools --vcf populations.snps.vcf --het
#  --> output file "out.het"  -  plot in Excel
# Sup Mat "inbreed_coeff"  
  
  
##PER LOCUS
#Fis info is contained in "populations.sumstats.tsv" file

#use script filter_fis.pl
cd $WORK/Pierre/stacks2.2/DIPLODUS_iter3/06-populations
perl filter_fis.pl populations.sumstats.tsv populations.snps.vcf > FisLoc_removed.recode.vcf

##count remaining loci:
grep  -c -v "^#" FisLoc_removed.recode.vcf

# Kept 44875 loci.
#  --> continue with output file "FisLoc_removed.recode.vcf"



# ------------------------------------------------------------


### LINKAGE DISEQUILIBRIUM - DETECT AND REMOVE LOCI IN LD

##   1. closer than 5000bp together

cd $WORK/Pierre/stacks2.2/DIPLODUS_iter3/06-populations
cp FisLoc_removed.recode.vcf $WORK/Pierre/stacks2.2/DIPLODUS_iter3/07-filtering
cd $WORK/Pierre/stacks2.2/DIPLODUS_iter3/07-filtering

#remove loci closer than certain distance apart:
vcftools \
  --vcf $WORK/Pierre/stacks2.2/DIPLODUS_iter3/07-filtering/FisLoc_removed.recode.vcf \
  --thin 5000 \
  --out FisLoc_removed_LD5000 \
  --recode

#kept 21585 loci
#  --> continue with output file "FisLoc_removed_LD5000.recode.vcf"



##   2.  R2 > 0,8

cd $WORK/Pierre/stacks2.2/DIPLODUS_iter3/07-filtering
#	1.	Identify loci with LD R2 > 0,8
screen
vcftools \
  --vcf $WORK/Pierre/stacks2.2/DIPLODUS_iter3/07-filtering/FisLoc_removed_LD5000.recode.vcf \
  --geno-r2
#  --> output file "out.geno.ld"
grep  -c -v "^#" out.geno.ld

#check that each comparison in the "out.geno.ld" file only occurs once, aka:
# A - B  ok 
# B - A  should not be there
# cannot check cuz file too large - assumed to be ok

#plot results with R-script "LDr2_plotted.R"

#Remove loci with r2 > 0,8
#create new directory and move .vcf file, out.geno.ld, and pl-script into new folder.
#add "#" to first line of "out.geno.ld"
cd $WORK/Pierre/stacks2.2/DIPLODUS_iter3/07-filtering
perl filter_LDr2.pl out.geno.ld FisLoc_removed_LD5000.recode.vcf > FisLoc_removed_LD5000r2.recode.vcf

#kept 21509 loci.

#  --> continue with output file "FisLoc_removed_LD5000r2.recode.vcf"


#count loc in new vcf file:
grep  -c -v "^#" FisLoc_removed_LD5000.recode.vcf	#pre-LDr2 removal
grep  -c -v "^#" FisLoc_removed_LD5000r2.recode.vcf	#post-LDr2 removal




# ------------------------------------------------------------


### min MAF (compare 0.01 and 0.05)

#filter out loci with a min MAF below 0.01 
cd $WORK/Pierre/stacks2.2/DIPLODUS_iter3/07-filtering
vcftools \
  --vcf $WORK/Pierre/stacks2.2/DIPLODUS_iter3/07-filtering/FisLoc_removed_LD5000r2.recode.vcf \
  --maf 0.01 \
  --out FisLoc_removed_LD5000r2_MAF001 \
  --recode



#filter out loci with a min MAF below 0.05
vcftools \
  --vcf $WORK/Pierre/stacks2.2/DIPLODUS_iter3/07-filtering/FisLoc_removed_LD5000r2.recode.vcf \
  --maf 0.05 \
  --out FisLoc_removed_LD5000r2_MAF005 \
  --recode



# ------------------------------------------------------------


### HWE

#filter out loci that are not in HWE (from MAF 0.05 filtering)
cd $WORK/Pierre/stacks2.2/DIPLODUS_iter3/07-filtering
vcftools \
  --vcf $WORK/Pierre/stacks2.2/DIPLODUS_iter3/07-filtering/FisLoc_removed_LD5000r2_MAF005.recode.vcf \
  --hwe 0.01 \
  --out FisLoc_removed_LD5000r2_MAF005_HWE \
  --recode


#filter out loci that are not in HWE (from MAF 0.01 filtering)
vcftools \
  --vcf $WORK/Pierre/stacks2.2/DIPLODUS_iter3/07-filtering/FisLoc_removed_LD5000r2_MAF001.recode.vcf \
  --hwe 0.01 \
  --out FisLoc_removed_LD5000r2_MAF001_HWE \
  --recode


# ------------------------------------------------------------



### CREATE NEUTRAL DATASET - REMOVE OUTLIERS WITH PCAdapt

#use Rscript "pcadapt_KF.R", run on laptop.

#remove outlier loci from lates .vcf file to obtain neutral dataset:
# OK 1.   double-check that the IDs in the "positions.txt" file correspond to the locus IDs in the .vcf file.
#    2.   I have 2 files, i) all_Pvalues_mullus.txt (p-value of each of the 4077 loci), 
#					  and ii) Outliers_Bonferroni_mullus.txt (loci identified as outliers by Bonferroni method)
# OK 3.   add "TABline" as a header to Outliers_Bonferroni_mullus.txt
# OK 4.   add "TABpvalue" as a header to all_Pvalues_mullus.txt
# OK 5.   from all_Pvalues_mullus.txt, extract all lines where x = "line" in Outliers_Bonferroni_mullus.txt
# OK  	   control that all these p-values are <<<<<<
#    6.   from .vcf file, remove each line present in Outliers_Bonferroni_mullus.txt
#        --> create new vcf file without outlier loci


cd $WORK/Pierre/stacks2.2/DIPLODUS_iter3/07-filtering

#MAF001:
#a) copy contents of 2nd column of "Outliers_Bonferroni_mullusMAF00x.txt" into new file called outliersMAF00x with nano.
#b) write first 2 columns of .vcf-file into a new file called "snp_pos.txt":
grep -v '^#' FisLoc_removed_LD5000r2_MAF001_HWE.recode.vcf |cut -f -2 > snp_posMAF001.txt
#c) take all lines from this new file that correspond to line number in the "Outlier" file, and write only those into a new file called "filter_pos.txt":
awk 'FNR==NR{a[$1];next}FNR in a' outliersMAF001.txt snp_posMAF001.txt >> filter_posMAF001.txt
#d) exclude outlier positions with vcftools from vcf file to obtain a neutral dataset:
vcftools --vcf FisLoc_removed_LD5000r2_MAF001_HWE.recode.vcf --exclude-positions filter_posMAF001.txt --recode --out FisLoc_removed_LD5000r2_MAF001_HWEneutral
#line count as a control:
grep  -c -v "^#" FisLoc_removed_LD5000r2_MAF001_HWEneutral.recode.vcf


#MAF005:
#a) copy contents of 2nd collumn of "Outliers_Bonferroni_mullusMAF00x.txt" into new file called outliersMAF00x with nano.
#b) write first 2 columns of .vcf-file into a new file called "snp_pos.txt":
grep -v '^#' FisLoc_removed_LD5000r2_MAF005_HWE.recode.vcf |cut -f -2 > snp_posMAF005.txt
#c) take all lines from this new file that correspond to line number in the "Outlier" file, and write only those into a new file called "filter_pos.txt":
awk 'FNR==NR{a[$1];next}FNR in a' outliersMAF005.txt snp_posMAF005.txt >> filter_posMAF005.txt
#d) exclude eutlier positions with vcftools from vcf file to obtain a neutral dataset:
vcftools --vcf FisLoc_removed_LD5000r2_MAF005_HWE.recode.vcf --exclude-positions filter_posMAF005.txt --recode --out FisLoc_removed_LD5000r2_MAF005_HWEneutral
#line count as a control:
grep  -c -v "^#" FisLoc_removed_LD5000r2_MAF005_HWEneutral.recode.vcf



# ------------------------------------------------------------


###COVERAGE PER SITE - remove sites with too high coverage

#check post-filtering coverage per site:
#cd $WORK/Pierre/stacks2.2/DIPLODUS_iter3/07-filtering
#vcftools --vcf FisLoc_removed_LD5000r2_MAF001_HWEneutral.recode.vcf --site-depth

#visualize sum_depth per site (Excel "Results_IBDPaper_SupMat.xlsx")

#make .txt file with loci to be excluded. Upload to server. ("exclude_positions.txt")
#cd $WORK/Pierre/stacks2.2/DIPLODUS_iter3/07-filtering
#dos2unix exclude_positions.txt

#remove sites with coverage > 25,000
#vcftools \
#  --vcf FisLoc_removed_LD5000r2_MAF001_HWEneutral.recode.vcf \
#  --exclude-positions exclude_positions.txt \
#  --out FisLoc_removed_LD5000r2_MAF001_HWEneutral_CovLoc_rem \
#  --recode

#test coverage per locus again
#vcftools --vcf FisLoc_removed_LD5000r2_MAF001_HWEneutral_CovLoc_rem.recode.vcf --site-depth --out LocCov_rem_depth



# ------------------------------------------------------------


###COVERAGE PER INDIVIDUAL  -  post-filtering
cd $WORK/Pierre/stacks2.2/DIPLODUS_iter3/07-filtering
vcftools --vcf FisLoc_removed_LD5000r2_MAF001_HWEneutral.recode.vcf --depth 

###COVERAGE PER SITE - post-filtering
cd $WORK/Pierre/stacks2.2/DIPLODUS_iter3/07-filtering
vcftools --vcf FisLoc_removed_LD5000r2_MAF001_HWEneutral.recode.vcf --site-depth

###MISSING DATA  -  post-filtering
cd $WORK/Pierre/stacks2.2/DIPLODUS_iter3/07-filtering
vcftools --vcf FisLoc_removed_LD5000r2_MAF001_HWEneutral.recode.vcf --missing-indv
vcftools --vcf FisLoc_removed_LD5000r2_MAF001_HWEneutral.recode.vcf --missing-site

###INBREEDING COEFFICIENT FIS PER INDIVIDUAL  -  post-filtering
cd $WORK/Pierre/stacks2.2/DIPLODUS_iter3/07-filtering
vcftools --vcf FisLoc_removed_LD5000r2_MAF001_HWEneutral.recode.vcf --het




# ------------------------------------------------------------


### IBD

#  1. 	calculate geographic distances
#		run on local machine ("IBD_marmap.R")


#  1b.  Downsample vcf file to 1500 loci

cd $WORK/Pierre/stacks2.2/DIPLODUS_iter3/07-filtering
grep '#' FisLoc_removed_LD5000r2_MAF001_HWEneutral.recode.vcf > FisLoc_removed_LD5000r2_MAF001_HWEneutral_1500Loci.recode.vcf #create new file that contains vcf header (15 lines)
#create vcf file that includes all BUT the lines with "#" (otherwise shuffling might also include #-lines
grep -v '^#' FisLoc_removed_LD5000r2_MAF001_HWEneutral.recode.vcf > takeFromHere.vcf #create new file that contains vcf header (15 lines)
#check if subsampling worked.
wc -l FisLoc_removed_LD5000r2_MAF001_HWEneutral.recode.vcf #1. count lines in overall doc=4119
grep  -c -v "^#" takeFromHere.vcf #2. count lines in the one that should exclude all #-lines=1404
wc -l FisLoc_removed_LD5000r2_MAF001_HWEneutral_1500Loci.recode.vcf #only #-lines=15 --> WORKED!

shuf -n 1500 takeFromHere.vcf >> FisLoc_removed_LD5000r2_MAF001_HWEneutral_1500Loci.recode.vcf #subsample vcf-contents to 200 loci, add those to file containing only the #-header so far
wc -l FisLoc_removed_LD5000r2_MAF001_HWEneutral_1500Loci.recode.vcf # =1515
grep  -c -v "^#" FisLoc_removed_LD5000r2_MAF001_HWEneutral_1500Loci.recode.vcf #check if subsampling worked=200 --> WORKED!



#  2.	calculate individual relatedness

#on MAF001 dataset
cd $WORK/Pierre/stacks2.2/DIPLODUS_iter3/07-filtering
vcftools --vcf $WORK/Pierre/stacks2.2/DIPLODUS_iter3/07-filtering/FisLoc_removed_LD5000r2_MAF001_HWEneutral.recode.vcf --relatedness 
mv out.relatedness out.relatedness_diplodusMAF001

#on MAF001 dataset SUBSET with 1500 loci
cd $WORK/Pierre/stacks2.2/DIPLODUS_iter3/07-filtering
vcftools --vcf FisLoc_removed_LD5000r2_MAF001_HWEneutral_1500Loci.recode.vcf --relatedness 
mv out.relatedness out.relatedness_diplodusMAF001_1500loci
awk '{ if ($1!=$2) print }' out.relatedness_diplodusMAF001_1500loci > out.relatedness_diplodusMAF001_1500loci_selfOut #remove self-comparisons



#on MAF005 dataset
cd $WORK/Pierre/stacks2.2/DIPLODUS_iter3/07-filtering/
vcftools --vcf $WORK/Pierre/stacks2.2/DIPLODUS_iter3/07-filtering/FisLoc_removed_LD5000r2_MAF005_HWEneutral.recode.vcf --relatedness 
mv out.relatedness out.relatedness_diplodusMAF005

#on MAF005 dataset SUBSET with 1500 loci
cp $WORK/Pierre/stacks2.2/DIPLODUS_iter3/09-IBD/Genepop/00-Overall/FisLoc_removed_LD5000r2_MAF005_HWEneutral_1500Loci.recode.vcf $WORK/Pierre/stacks2.2/DIPLODUS_iter3/07-filtering
cd $WORK/Pierre/stacks2.2/DIPLODUS_iter3/07-filtering
vcftools --vcf FisLoc_removed_LD5000r2_MAF005_HWEneutral_1500Loci.recode.vcf --relatedness 
mv out.relatedness out.relatedness_diplodusMAF005_1500loci
awk '{ if ($1!=$2) print }' out.relatedness_diplodusMAF005_1500loci > out.relatedness_diplodusMAF005_1500loci_selfOut #remove self-comparisons



#   3.  Remove self-comparisons from geographic distance matrices.

#load "out.relatedness...." files, "marmap_mullus_distances_grid_312ind.txt", "marmap_mullus_EuclDistances_grid_312ind.txt" onto server.
cd $WORK/Pierre/stacks2.2/DIPLODUS_iter3/09-IBD/rm_self_comparisons
awk '{ if ($2!=$3) print }' geoGenA_MAF005_1500loci.txt > geoGenA_MAF005_1500loci_selfOut.txt



#	4.	Compute Rousset's e (with Genepop on the web: http://genepop.curtin.edu.au/genepop_op6.html)

#convert vcf file to Genepop format (on local laptop with PGDSpider)
#convert Genepop file to specific input file (specified here: http://genepop.curtin.edu.au/Option6.html)

cd $WORK/Pierre/stacks2.2/DIPLODUS_iter3/09-IBD/Genepop/00-Overall/1500loci/01-MAF005
#remove ".sorted" from Genepop file.
#add genepop-file, gps-file, and genepop_gps.pl to this folder.
#when uploading from a Windows-computer, run the following command:
dos2unix diplodus_gps.txt
dos2unix Genepop_diplodus_MAF005_1500loci.txt
dos2unix genepop_gps.pl

#convert file to adjusted Genepop format:
perl genepop_gps.pl diplodus_gps.txt Genepop_diplodus_MAF005_1500loci.txt > Genepop_for_Rousset_diplodus_MAF005_1500.txt

#calculate Rousset's e using S. Kniefs script:
#make sure startinter.sh, R-script, and Genepop-fo-Rousset.txt file are in dir
ssh neshcl343
cd $WORK/Pierre/stacks2.2/DIPLODUS_iter3/09-IBD/Genepop/00-Overall/1500loci/00-MAF001
# directory needs to contain startinter.sh, R-script, Genepop file
chmod u+x startinter.sh
nohup ./startinter.sh &



#	5.	Mantel test
#		run on local machine using mantel from the package ecodist ("IBD_marmap.R")


#




# ------------------------------------------------------------


### ADMIXTURE

cd $WORK/01_software
wget http://software.genetics.ucla.edu/admixture/binaries/admixture_linux-1.3.0.tar.gz
tar xfvz admixture_linux-1.3.0.tar.gz

#to execute:
$WORK/01_software/admixture_linux-1.3.0/admixture


##### 		FULL dataset (not only MPAs) 		#####


#use imissIndFisLoc_removed_LD5000LDr2.recode.vcf (in $WORK/Pierre/stacks2.2/DIPLODUS/07-filtering)
#use vcftools to make tped and tfam files:
cp $WORK/Pierre/stacks2.2/DIPLODUS/07-filtering/imissIndFisLoc_removed_LD5000LDr2.recode.vcf $WORK/Pierre/stacks2.2/DIPLODUS/06a-vcf_file_creation
cd $WORK/Pierre/stacks2.2/DIPLODUS/10-Admixture
vcftools --vcf $WORK/Pierre/stacks2.2/DIPLODUS/06a-vcf_file_creation/imissIndFisLoc_removed_LD5000LDr2.recode.vcf --plink-tped --out FULL_imissIndFisLoc_removed_LD5000LDr2  #creates tped and tfam files

#create MPA name file from vcf-file:

plink --tped FULL_imissIndFisLoc_removed_LD5000LDr2.tped --tfam FULL_imissIndFisLoc_removed_LD5000LDr2.tfam --make-bed # use tped&tfam files to create bed file
mv plink.bed FULL_imissIndFisLoc_removed_LD5000LDr2.bed
mv plink.bim FULL_imissIndFisLoc_removed_LD5000LDr2.bim
mv plink.fam FULL_imissIndFisLoc_removed_LD5000LDr2.fam

$WORK/01_software/admixture_linux-1.3.0/admixture

$WORK/01_software/admixture_linux-1.3.0/admixture --cv FULL_imissIndFisLoc_removed_LD5000LDr2.bed 1 -s time -B[2000] > FULL_imissIndFisLoc_removed_LD5000LDr2.log
$WORK/01_software/admixture_linux-1.3.0/admixture --cv FULL_imissIndFisLoc_removed_LD5000LDr2.bed 2 -s time -B[2000] >> FULL_imissIndFisLoc_removed_LD5000LDr2.log
$WORK/01_software/admixture_linux-1.3.0/admixture --cv FULL_imissIndFisLoc_removed_LD5000LDr2.bed 3 -s time -B[2000] >> FULL_imissIndFisLoc_removed_LD5000LDr2.log
$WORK/01_software/admixture_linux-1.3.0/admixture --cv FULL_imissIndFisLoc_removed_LD5000LDr2.bed 4 -s time -B[2000] >> FULL_imissIndFisLoc_removed_LD5000LDr2.log
$WORK/01_software/admixture_linux-1.3.0/admixture --cv FULL_imissIndFisLoc_removed_LD5000LDr2.bed 5 -s time -B[2000] >> FULL_imissIndFisLoc_removed_LD5000LDr2.log
$WORK/01_software/admixture_linux-1.3.0/admixture --cv FULL_imissIndFisLoc_removed_LD5000LDr2.bed 6 -s time -B[2000] >> FULL_imissIndFisLoc_removed_LD5000LDr2.log
$WORK/01_software/admixture_linux-1.3.0/admixture --cv FULL_imissIndFisLoc_removed_LD5000LDr2.bed 7 -s time -B[2000] >> FULL_imissIndFisLoc_removed_LD5000LDr2.log
$WORK/01_software/admixture_linux-1.3.0/admixture --cv FULL_imissIndFisLoc_removed_LD5000LDr2.bed 8 -s time -B[2000] >> FULL_imissIndFisLoc_removed_LD5000LDr2.log

#paste all results together:
grep -h CV FULL_imissIndFisLoc_removed_LD5000LDr2.log>FULL_imissIndFisLoc_removed_LD5000LDr2_cross_validation

#to plot results, have separate file with individual names. Plot in Excel.
echo "sample" > FULL_Ind_names.txt
#append sample IDs to that file. Reason: have file in which sample IDs are in same order as in the vcf SNP file
grep "#CHROM" $WORK/Pierre/stacks2.2/DIPLODUS/06a-vcf_file_creation/imissIndFisLoc_removed_LD5000LDr2.recode.vcf |cut -f 10- |sed 's/\t/\n/g' >> FULL_Ind_names.txt
#manually remove ".copy" and ".sorted" from name list, add GPS coordinates (to sort them well)



# ------------------------------------------------------------


### DAPC

#use script "DAPC_diplodus.R"  (on laptop). 




# ------------------------------------------------------------




### CREATE VCF FILES WITH MPAS ONLY AND WITH FULL DATASETS  **)
# for following pop gen analyses

#use pop_mullus45 .vcf file:
#MPAyes:
mkdir $WORK/Pierre/stacks2.2/06a-vcf_file_creation

cd $WORK/Pierre/stacks2.2/12-LD/pop_mullus44
cp LD5000_popmul44.recode.vcf $WORK/Pierre/stacks2.2/06a-vcf_file_creation
cd $WORK/Pierre/stacks2.2/06a-vcf_file_creation
#make txt-file with inds to keep (from "GeneticData_Parameters_Mullus_20181203_KF.xlsx")
#"keep_indsMPAyes.txt", #"keep_indsMPAyesclose.txt"

#Make new vcf files with only those individuals.
#this step is not needed for full dataset.
vcftools --vcf LD5000_popmul44.recode.vcf --keep keep_indsMPAyes.txt --out MPAyes__r1 --recode
vcftools --vcf LD5000_popmul44.recode.vcf --keep keep_indsMPAyesclose.txt --out MPAyesclose_r1 --recode
vcftools --vcf LD5000_popmul44.recode.vcf --keep keep_indsFULL.txt --out FULL_r1 --recode



# ------------------------------------------------------------




### Fst Population Statistics

#use GenoDive for pairwise Fst estimates.
#input files (vcf from pop_mullus45 -> transform with vcftools (see **) above)
# -> convert to structure (PGDSpider) -> use Tills script: include pop names
# -> convert pop names back to integers (proper structure format)

#make sure that SPID file is in 13-PGDSpider folder.
#use 6 files from this folder (r1 & r085, Full & MPAyes & MPAyesmaybe):
$WORK/Pierre/stacks2.2/06a-vcf_file_creation
#names of files from 06a-vcf_file_creation-folder to be converted to Structure:
#FULL_r1.recode.vcf
#MPAyesclose_r1.recode.vcf
#MPAyes_r1.recode.vcf
#FULL_r0.85.recode.vcf
#MPAyesclose_r0.85.recode.vcf
#MPAyes_r0.85.recode.vcf

cd $WORK/Pierre/stacks2.2/13-PGDSpider

#convert files from vcf to Structure format:
java -Xmx3024m -Xms512m -jar $WORK/01_software/PGDSpider_2.1.1.5/PGDSpider2-cli.jar \
  -inputfile $WORK/Pierre/stacks2.2/06a-vcf_file_creation/MPAyes_r0.85.recode.vcf \
  -inputformat VCF \
  -outputfile MPAyes_r0.85_Structure \
  -outputformat STRUCTURE, \
  -spid VCF_to_STRUCTURE.spid

#open pop_map files in Notepad and go to Edit -> EOL conversion -> Unix.
#Upload and move 3 pop_map files into 13-PGDSpider.
#add pop names to Structure file:
perl -F'\t' -anle 'BEGIN{ open my $FILE, "<",
"mullus_population_map_MPAyes.txt" or die "Could not open file
mullus_population_map_MPAyes.txt:!$\n"; %h = map {chomp; split
/\t/, $_} <$FILE> }; if($. == 1) { print; next}; if (exists $h{$F[0]})
{print "$F[0]\t$h{$F[0]}\t$F[2]"} else{die"Cound not find $F[0] in
list\n"}' MPAyes_r1_Structure > MPAyes_r1_popnames_Structure

#copy resulting files to Laptop for GenoDive analyses:
cp $WORK/Pierre/stacks2.2/13-PGDSpider/LD5000_Bayescan $WORK/Pierre/stacks2.2/14-Bayescan

#manually change popnames in 3 Structure files to numbers 
#(see "replace_popnames_by_numbers.xlsx" in 13-PGDSpider)
#safe as "xx_popnames_num_xx" in 13-PGDSpider.

# ------------------------------------------------------------







#check if 2 files are identical:
cd $WORK/Pierre/stacks2.2/06a-vcf_file_creation/
cmp --silent FULL_r0.85.recode.vcf LD5000.recode.vcf && echo '### SUCCESS: Files Are Identical! ###' || echo '### WARNING: Files Are Different! ###'
# --> they are identical.


