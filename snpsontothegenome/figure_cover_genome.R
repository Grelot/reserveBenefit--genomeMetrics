library(ggplot2)
library(plyr)
library(reshape)
library(reshape2)
library(gridExtra)

cover_genome_figures <- function(species_name,titre1,titre2) {
  print(species_name)
  ## load table scaffold/left/right/coverage with row as windows
  don=read.table(paste(species_name,"_coverage.bed",sep=""),header=F)
  ## load bed files with depth coverage for each individual for each loci, and locus have a windows
  don2=read.table(paste(species_name,"_meandepth.bed",sep=""),header=F)

  ## data frame which define windows into scaffold and corresponding coverage
  dd=data.frame(scaffold=don[,1],left=don[,2],right=don[,3],cover=don[,4])
  id_win=seq(1,length(dd$right))
  dd.w=data.frame(scaffold=don[,1],windows=id_win,cover=don[,4])
  dorder=unique(dd$scaffold)
  dd.w[match(dorder, dd.w$scaffold),]
  ## variants depth coverage for each individuals
  covers=don2[,7:dim(don2)[2]]
  variant_info=don2[,c(1,2,3)]
  names(variant_info)=c("scaffold","left","right")
  dd.win=data.frame(scaffold=don[,1],left=don[,2],right=don[,3],windows=id_win)
  variant.win=merge(variant_info, dd.win, c("scaffold","left","right"))
  covers.win=cbind(variant.win, covers)
  dm.win=cbind(variant.win,rowMeans(covers,na.rm=T))
  names(dm.win)=c("scaffold","left","right","windows","meanDepth")
  ## define rectangle as length of each scaffold
  sc.sca=c()
  sc.right=c()
  sc.left=c()
  for(sc in unique(dd.w$scaffold)){
    sc.dd=dd.w[which(dd.w$scaffold==sc),]
    sc.left=c(sc.left, min(sc.dd$windows))
    sc.right=c(sc.right, max(sc.dd$windows))
    sc.sca=c(sc.sca,sc)
  }
  scadd=data.frame(scaffold=sc.sca,left=sc.left,right=sc.right)
  scadd.1=scadd[which(scadd$right-scadd$left > 1),]
  rectangles <- data.frame(
    xmin = scadd.1$left,
    xmax = scadd.1$right,
    ymin = rep(0,length(scadd.1$left)),
    ymax = rep(100,length(scadd.1$left))
  )
  row_id.tokeep=seq(from=1,to=length(scadd.1$left),by=2)
  rectangles.toprint=rectangles[row_id.tokeep,]
  dd.wg=dd.w[which(dd.w$scaffold %in% scadd.1$scaffold),]
  dm.wing=dm.win[which(dm.win$scaffold %in% scadd.1$scaffold),]
  dm.winga=aggregate(meanDepth ~ windows, data = dm.wing, mean)
  covers.wing=covers.win[which(covers.win$scaffold %in% scadd.1$scaffold),]
  variant.wing=variant.win[which(variant.win$scaffold %in% scadd.1$scaffold),]
  ## [!] very long (write a file of 100000000 rows)
  dv.wing <- melt(covers.wing, id=(c("scaffold", "left","right","windows")))
  ## filter outliers variant with very high coverage
  dv.wing.cutoff=dv.wing[which(dv.wing$value < 200),]

  ## plot figures
  p_numbervar=ggplot() +
    geom_rect(data=rectangles.toprint, aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax), 
              fill='gray80', alpha=0.8)+
    geom_line(data=dd.wg,aes(x=windows,y=cover),size=0.6,color="black")+
    xlab("")+ylab("Number of variants")+ggtitle(titre1)+ylim(0, 100)+
    scale_x_continuous( labels=function(x) round(x/2.5,digits=0) )+
    theme_classic()
  p_depthcov=ggplot() +
    geom_rect(data=rectangles.toprint, aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax+100), 
              fill='gray80', alpha=0.8)+  
    geom_point(data=dv.wing.cutoff,aes(x=windows,y=value),size=0.05,alpha=0.3,color="royalblue")+
    geom_line(data=dm.winga,aes(x=windows,y=meanDepth),size=0.6,color="black")+
    xlab("Base position (Mb)")+ylab("Depth coverage")+ggtitle(titre2)+ylim(0, 200)+
    scale_x_continuous( labels=function(x) round(x/2.5,digits=0))+
    theme_classic()+
    theme(
      plot.title = element_text(size = 24),
      axis.title = element_text(size = 20),
      axis.text = element_text(size = 18))
  return(list(p_numbervar,p_depthcov))
}

diplodusplots=cover_genome_figures("diplodus","(A)","(B)")
mullusplots=cover_genome_figures("mullus","(C)","(D)")
serranplots=cover_genome_figures("serran","(E)","(F)")



pdf("depthcoverage_numberofvar.pdf",width=14,height=7,paper='special')
grid.arrange(diplodusplots[[1]],mullusplots[[1]],serranplots[[1]],diplodusplots[[2]], mullusplots[[2]],serranplots[[2]],nrow=2)
dev.off()


png("depthcoverage_numberofvar.png",width=1944,height=1024)
grid.arrange(diplodusplots[[1]],mullusplots[[1]],serranplots[[1]],diplodusplots[[2]], mullusplots[[2]],serranplots[[2]],nrow=2)
dev.off()

#######################################################

