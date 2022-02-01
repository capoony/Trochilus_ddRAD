## visualize the summary statistics


path=$1



mkdir -p ${path}/stat
echo """

#dependencies
library(plyr)
library(ggplot2)
library(tidyverse)
library(akima)
library(gridExtra)

df <- read.table('${path}_stats.txt',header=T,na.string='na')
df1<-df %>%
  #select(Name,i) %>%
  separate(Name,c('m','M','n'),
    sep='_',
    convert=T)%>%
  filter(PropCovLoci %in% c(0.5,0.75,1.0),
  m %in% c(3,5,7),
  M %in% c(1,2, 3, 4, 6, 8, 10, 15, 20, 30),
  n %in% c(1,2, 3, 4, 6, 8, 10, 15, 20, 30))

df1\$PropCovLoci<-sub('^','Prop. samples (-R): ',df1\$PropCovLoci)
df1\$m<-sub('^','Minimum stack depth (-m): ',df1\$m)
df1\$n<-factor(df1\$n)

#i='NoLoci'
for (i in c('SNPCount' ,'SNPdensity','Het')){
  AV=paste0('CummAv',i)
  SD=paste0('CummSD',i)
  df1\$ymin=df1[[AV]]-df1[[SD]]
  df1\$ymax=df1[[AV]]+df1[[SD]]
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
# ggsave(paste0('${path}/summary_',i,'.png'),width=12,height=6)

Plot<-ggplot(df1, aes_string(x='M', y = AV,col='n',fill='n')) +
  geom_line()+
  #geom_ribbon(aes(ymin=ymin,ymax=ymax),alpha=0.1,colour=NA)+
  theme_bw()+
  xlab('Distance allowed between stacks (-M)')+
  guides(col=guide_legend(title='Distance allowed\nbetween catalog loci\n(-n)'))+
  guides(fill=guide_legend(title='Distance allowed\nbetween catalog loci\n(-n)'))+
  facet_grid(PropCovLoci~m)

ggsave(paste0('${path}/stat/summary_line_',i,'.png'),width=12,height=6)

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
# ggsave('${path}/summary_CummNoLoci.png',width=12,height=6)

Plot<-ggplot(df1, aes_string(x='M', y = 'CummNoLoci',col='n')) +
  geom_line()+
  theme_bw()+
  xlab('Distance allowed between stacks (-M)')+
  guides(col=guide_legend(title='Distance allowed\nbetween catalog loci\n(-n)'))+
  facet_grid(PropCovLoci~m, scales='free')

ggsave('${path}/stat/summary_line_CummNoLoci.png',width=12,height=6)
""" > ${path}/stat.r

Rscript ${path}/stat.r

mkdir -p ${path}/cov

echo """

#dependencies
library(ggplot2)
library(tidyverse)
library(akima)
library(gridExtra)

df <- read.table('${path}_cov.txt',header=T,na.string='na')

for (j in c(0.5,0.75,1.0)){

  for (i in levels(as.factor(df\$Sample))){

    df1<-df %>%
      #select(Name,i) %>%
      separate(Name,c('m','M','n'),sep='_' ,
      convert=T)%>%
      filter(Sample==i,
        PropCovLoci==j,
        m %in% c(3,5,7),
        M %in% c(1,2, 3, 4, 6, 8, 10, 15, 20, 30),
        n %in% c(1,2, 3, 4, 6, 8, 10, 15, 20, 30))
    df1\$Poly[df1\$Poly==0]<-'Monomorphic'
    df1\$Poly[df1\$Poly==1]<-'Polymorphic'
    df1\$m<-sub('^','Minimum stack depth (-m): ',df1\$m)
    df1\$n<-factor(df1\$n)

    # colors = c('purple','blue','cyan','green','yellow','red')
    # ###
    # Plot<-ggplot(df1, aes_string('M', 'n', z = 'AvCov')) +
    #   stat_summary_2d(geom = 'raster', bins = 30) +
    #   scale_fill_gradientn(colours = colors)+
    #   theme_bw()+
    #   ggtitle(paste0('Average Coverage; PropCovLoci: ',j))+
    #   guides(fill=guide_legend(title='Distance allowed\nbetween catalog loci\n(-n)'))+
    #   facet_grid(Poly~m)
    #
    # ggsave(paste0('${path}/cov/cov_',i,'_',j,'.png'),width=12,height=6)

    Plot<-ggplot(df1, aes_string(x='M', y = 'AvCov',col='n')) +
      geom_line()+
      theme_bw()+
      xlab('Distance allowed between stacks (-M)')+
      guides(col=guide_legend(title='Distance allowed\nbetween catalog loci\n(-n)'))+
      facet_grid(Poly~m,scales='free')

    ggsave(paste0('${path}/cov/cov_line_',i,'_',j,'.png'),width=12,height=6)
  }
}

df\$Poly[df\$Poly==0]<-'Monomorphic'
df\$Poly[df\$Poly==1]<-'Polymorphic'


df2<-spread(df, key = Poly, value = AvCov)
df2.sum<-df2 %>%
  #select(Name,i) %>%
  separate(Name,c('m','M','n'),sep='_' ,
  convert=T)%>%
  mutate('Monomorphic/Polymorphic'=Monomorphic/Polymorphic)

df2.sum\$n<-factor(df2.sum\$n)
df2.sum\$m<-sub('^','Minimum stack depth (-m): ',df2.sum\$m)
df2.sum\$Sample<-sub('^','Sample name: ',df2.sum\$Sample)

Plot<-ggplot(df2.sum, aes_string(x='M', y = 'Monomorphic/Polymorphic',col='n')) +
  geom_line()+
  theme_bw()+
  xlab('Distance allowed between stacks (-M)')+
  guides(col=guide_legend(title='Distance allowed\nbetween catalog loci\n(-n)'))+
  facet_grid(Sample~m,scales='free')

ggsave('${path}/cov/cov_diff.png',width=12,height=18)

df2.cov<-df %>%
  group_by(Sample)%>%
  summarize(Coverage=mean(AvCov))

Plot<-ggplot(df2.cov, aes(x=as.factor(Sample), y = Coverage)) +
  geom_bar(stat ='identity')+
  theme_bw()+
  xlab('Sample Name')

ggsave('${path}/cov/cov_av.png',width=8,height=4)

""" > ${path}/cov.r

Rscript ${path}/cov.r

#cp -r /media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full ~/winuser
