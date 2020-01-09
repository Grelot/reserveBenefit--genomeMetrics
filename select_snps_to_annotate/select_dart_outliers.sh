## from dirty files *outliers_[species].txt" extract selected loci into DART/[species]


## serranus
SELECTED_DIRT_SNPS="select_snps_to_annotate/262outliers_serranus.txt"
ALL_DART_SNPS="select_snps_to_annotate/DART/serranus/Report_DSr19-4321_SNP_mapping_3.csv"
SPECIES="serran"


SELECTED_ID_SNPS="select_snps_to_annotate/"$SPECIES"_select_id.txt"
awk '{ print $3}' $SELECTED_DIRT_SNPS | grep -e "^X" | cut -f 1 -d "." | cut -c2- > $SELECTED_ID_SNPS


SELECTED_DART_SNPS=$SPECIES"_select_dart.csv"
grep -f $SELECTED_ID_SNPS $ALL_DART_SNPS > $SELECTED_DART_SNPS


## reformat: scaffold; position; sequence ref; sequence alt; dart id
awk -F "," '{ if($5 != "") print $5"\t"$6"\t"$3"\t"$4"\t"$2}' $SELECTED_DART_SNPS > select_snps_to_annotate/selected_loci_"$SPECIES".tsv
