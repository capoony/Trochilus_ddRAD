

#dependencies
library(plyr)
library(ggplot2)
library(tidyverse)
library(akima)
library(gridExtra)

df <- read.table("/media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/ohne/summary_stats.txt",header=T)
df1<-df %>%
  #select(Name,i) %>%
  separate(Name,c("m","M","n"),
    sep="_",
    convert=T)%>%
  filter(PropCovLoci %in% c(0.5,0.75,1.0) )

df1$PropCovLoci<-sub("^","Prop. samples (-R): ",df1$PropCovLoci)
df1$m<-sub("^","Minimum stack depth (-m): ",df1$m)
df1$n<-factor(df1$n)

i="NoLoci"
for (i in c("CummAvSNPCount"  ,"CummSDSNPCount","CummAvSNPdensity","CummSDSNPdenisty")){
colors = c("purple","blue","cyan","green","yellow","red")
#create plot
Plot<-ggplot(df1, aes_string("M", "n", z = i)) +
  stat_summary_2d(geom = "raster", bins = 30) +
  scale_fill_gradientn(colours = colors)+
  theme_bw()+
  xlab("Distance allowed between stacks (-M)")+
  guides(fill=guide_legend(title="Distance allowed\nbetween catalog loci\n(-n)"))+
  ggtitle(i)+
  facet_grid(PropCovLoci~m)

ggsave(paste0("/media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/ohne/stat/summary_",i,".png"),width=12,height=6)

Plot<-ggplot(df1, aes_string(x="M", y = i,col="n")) +
  geom_line()+
  theme_bw()+
  xlab("Distance allowed between stacks (-M)")+
  guides(col=guide_legend(title="Distance allowed\nbetween catalog loci\n(-n)"))+
  facet_grid(PropCovLoci~m)

ggsave(paste0("/media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/ohne/stat/summary_line_",i,".png"),width=12,height=6)

}

### Log-scale for # loci
Plot<-ggplot(df1, aes_string("M", "n", z = "CummNoLoci")) +
  stat_summary_2d(geom = "raster", bins = 30) +
  scale_fill_gradientn(colours = colors, trans="log10")+
  theme_bw()+
  guides(fill=guide_legend(title="Distance allowed\nbetween catalog loci\n(-n)"))+
  ggtitle("CummNoLoci")+
  facet_grid(PropCovLoci~m)

ggsave("/media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/ohne/stat/summary_CummNoLoci.png",width=12,height=6)

Plot<-ggplot(df1, aes_string(x="M", y = "CummNoLoci",col="n")) +
  geom_line()+
  theme_bw()+
  xlab("Distance allowed between stacks (-M)")+
  guides(col=guide_legend(title="Distance allowed\nbetween catalog loci\n(-n)"))+
  facet_grid(PropCovLoci~m, scales="free")

ggsave("/media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/ohne/stat/summary_line_CummNoLoci.png",width=12,height=6)

