###############################################################################
## load data

species_name="diplodus"

coords=read.table(paste(species_name,"_coords.snps.bed",sep=""),header=F)
names(coords)=c("scaffold","position")

###############################################################################
## for each scaffold get consecutive pair of SNPS and distance between them

total_dist=c()
for(sca in levels(coords$scaffold)){
	local_pos=coords[which(coords$scaffold==as.character(sca)),]
	print(sca)
	if(dim(local_pos)[1]>2) {
		local_dist=c()
		for(i in 2:length(local_pos[,2])) {
			pos_dist=as.numeric(local_pos[i,2])-as.numeric(local_pos[i-1,2])
			dist_df=data.frame(scaffold=sca, distance=pos_dist)
			local_dist=rbind(local_dist,dist_df)
		}
		total_dist=rbind(total_dist,local_dist)
	}
}

