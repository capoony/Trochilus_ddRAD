

#dependencies
library(plyr)
library(ggplot2)
library(tidyverse)
library(akima)
library(gridExtra)

df <- read.table('/media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full/no_filter_stats.txt',header=T,na.string='na')
df1<-df %>%
  #select(Name,i) %>%
  separate(Name,c('m','M','n'),
    sep='_',
    convert=T)%>%
  filter(PropCovLoci %in% c(0.5,0.75,1.0),
  m %in% c(3,5,7),
  M %in% c(1,2, 3, 4, 6, 8, 10, 15, 20, 30),
  n %in% c(1,2, 3, 4, 6, 8, 10, 15, 20, 30))

df1$PropCovLoci<-sub('^','Prop. samples (-R): ',df1$PropCovLoci)
df1$m<-sub('^','Minimum stack depth (-m): ',df1$m)
df1$n<-factor(df1$n)

#i='NoLoci'
for (i in c('SNPCount' ,'SNPdensity','Het')){
  AV=paste0('CummAv',i)
  SD=paste0('CummSD',i)
  df1$ymin=df1[[AV]]-df1[[SD]]
  df1$ymax=df1[[AV]]+df1[[SD]]
colors = c('purple','blue','cyan','green','yellow','red')
#create plot
# Plot<-ggplot(df1, aes_string('M', 'n', z = i)) +
#   stat_summary_2d(geom = 'raster', bins = 30) +
#   scale_fill_gradientn(colours = colors)+
#   theme_bw()+
#   xlab('Distance allowed between stacks (-M)')+
#   guides(fill=guide_legend(title='Distance allowed\nbetween catalog loci\n(-n)'))+
#   ggtitle(i)+
#   facet_grid(PropCovLoci~m)
#
# ggsave(paste0('/media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full/no_filter/summary_',i,'.png'),width=12,height=6)

Plot<-ggplot(df1, aes_string(x='M', y = AV,col='n',fill='n')) +
  geom_line()+
  #geom_ribbon(aes(ymin=ymin,ymax=ymax),alpha=0.1,colour=NA)+
  theme_bw()+
  xlab('Distance allowed between stacks (-M)')+
  guides(col=guide_legend(title='Distance allowed\nbetween catalog loci\n(-n)'))+
  guides(fill=guide_legend(title='Distance allowed\nbetween catalog loci\n(-n)'))+
  facet_grid(PropCovLoci~m)

ggsave(paste0('/media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full/no_filter/stat/summary_line_',i,'.png'),width=12,height=6)

}

### Log-scale for # loci
# Plot<-ggplot(df1, aes_string('M', 'n', z = 'CummNoLoci')) +
#   stat_summary_2d(geom = 'raster', bins = 30) +
#   scale_fill_gradientn(colours = colors, trans='log10')+
#   theme_bw()+
#   guides(fill=guide_legend(title='Distance allowed\nbetween catalog loci\n(-n)'))+
#   ggtitle('CummNoLoci')+
#   facet_grid(PropCovLoci~m)
#
# ggsave('/media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full/no_filter/summary_CummNoLoci.png',width=12,height=6)

Plot<-ggplot(df1, aes_string(x='M', y = 'CummNoLoci',col='n')) +
  geom_line()+
  theme_bw()+
  xlab('Distance allowed between stacks (-M)')+
  guides(col=guide_legend(title='Distance allowed\nbetween catalog loci\n(-n)'))+
  facet_grid(PropCovLoci~m, scales='free')

ggsave('/media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full/no_filter/stat/summary_line_CummNoLoci.png',width=12,height=6)

