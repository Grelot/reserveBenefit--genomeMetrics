###############################################################################
## function



average_distance_loci <- function(species_name) {
	coords=read.table(paste(species_name,"_coords.snps.bed",sep=""),header=F)
	names(coords)=c("scaffold","position")
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
	return(total_dist)
}


###############################################################################

diplodus_dist_loci=average_distance_loci("diplodus")
mullus_dist_loci=average_distance_loci("mullus")
serran_dist_loci=average_distance_loci("serran")

## average distance loci
mean_v=c(
mean(diplodus_dist_loci[,2]),
mean(mullus_dist_loci[,2]),
mean(serran_dist_loci[,2])
)


## median distance loci
media_v=c(
median(diplodus_dist_loci[,2]),
median(mullus_dist_loci[,2]),
median(serran_dist_loci[,2])
)

## sd distance loci
sd_v=c(
sd(diplodus_dist_loci[,2]),
sd(mullus_dist_loci[,2]),
sd(serran_dist_loci[,2])
)

## max distance loci
max_v=c(
max(diplodus_dist_loci[,2]),
max(mullus_dist_loci[,2]),
max(serran_dist_loci[,2])
)

## min distance loci
min_v=c(
min(diplodus_dist_loci[,2]),
min(mullus_dist_loci[,2]),
min(serran_dist_loci[,2])
)

distance_loci=matrix(c(mean_v,media_v,sd_v,max_v,min_v),nrow=3)
row.names(distance_loci)=c("diplodus","mullus","serran")
colnames(distance_loci)=c("mean","median","sd","max","min")


###############################################################################
## write csv
write.csv(distance_loci)