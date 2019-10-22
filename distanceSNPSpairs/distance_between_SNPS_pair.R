###############################################################################
## functions

scaffold_dist_df <- function(local_snppos) {
	ids=seq(1,length(local_snppos$scaffold))
	idsPairs=t(combn(ids, 2))

	l <- as.list(local_snppos[,"position"])
	names(l)<-ids
	snpsPos=t(combn(l, 2))

	distSnps=as.numeric(snpsPos[,2])-as.numeric(snpsPos[,1])
	localScaffold=rep(as.character(local_snppos$scaffold[1]),length(distSnps))

	snpsDistDf=data.frame(idSNP1=as.numeric(idsPairs[,1]),idSNP2=as.numeric(idsPairs[,2]), scaffold=localScaffold,positionSNP1=as.numeric(snpsPos[,1]),positionSNP2=as.numeric(snpsPos[,2]),distance=distSnps)
	return(snpsDistDf)
}


###############################################################################
## load data
test =read.table("07-post/mullus_big_scaffolds_snps_pos.tsv")
#test =read.table("07-post/mullus_snps_pos.tsv")
names(test)=c("scaffold","position")

###############################################################################
## for each scaffold get pair of SNPS and distance between them

total_distDf=c()
for(i in levels(test$scaffold)){
	local_pos=test[which(test$scaffold==as.character(i)),]
	if(dim(local_pos)[1]>2) {
		local_distDf=scaffold_dist_df(local_pos)
		total_distDf=rbind(total_distDf,local_distDf)
	}
}

###############################################################################
## write table

write.table(total_distDf,file="07-post/mullus_big_scaffolds_snps_pairs_distance.tsv",row.names=F,quote=F,sep="\t")