

#dependencies
library(ggplot2)
library(tidyverse)
library(akima)
library(gridExtra)

df <- read.table('/media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full_trimmed/no_filter_cov.txt',header=T,na.string='na')

for (j in c(0.5,0.75,1.0)){

  for (i in levels(as.factor(df$Sample))){

    df1<-df %>%
      #select(Name,i) %>%
      separate(Name,c('m','M','n'),sep='_' ,
      convert=T)%>%
      filter(Sample==i,
        PropCovLoci==j,
        m %in% c(3,5,7),
        M %in% c(1,3,6,10,12),
        n %in% c(1,3,6,10,12))
    df1$Poly[df1$Poly==0]<-'Monomorphic'
    df1$Poly[df1$Poly==1]<-'Polymorphic'
    df1$m<-sub('^','Minimum stack depth (-m): ',df1$m)
    df1$n<-factor(df1$n)

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
    # ggsave(paste0('/media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full_trimmed/no_filter/cov/cov_',i,'_',j,'.png'),width=12,height=6)

    Plot<-ggplot(df1, aes_string(x='M', y = 'AvCov',col='n')) +
      geom_line()+
      theme_bw()+
      xlab('Distance allowed between stacks (-M)')+
      guides(col=guide_legend(title='Distance allowed\nbetween catalog loci\n(-n)'))+
      facet_grid(Poly~m,scales='free')

    ggsave(paste0('/media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full_trimmed/no_filter/cov/cov_line_',i,'_',j,'.png'),width=12,height=6)
  }
}

df$Poly[df$Poly==0]<-'Monomorphic'
df$Poly[df$Poly==1]<-'Polymorphic'


df2<-spread(df, key = Poly, value = AvCov)
df2.sum<-df2 %>%
  #select(Name,i) %>%
  separate(Name,c('m','M','n'),sep='_' ,
  convert=T)%>%
  mutate('Monomorphic/Polymorphic'=Monomorphic/Polymorphic)

df2.sum$n<-factor(df2.sum$n)
df2.sum$m<-sub('^','Minimum stack depth (-m): ',df2.sum$m)
df2.sum$Sample<-sub('^','Sample name: ',df2.sum$Sample)

Plot<-ggplot(df2.sum, aes_string(x='M', y = 'Monomorphic/Polymorphic',col='n')) +
  geom_line()+
  theme_bw()+
  xlab('Distance allowed between stacks (-M)')+
  guides(col=guide_legend(title='Distance allowed\nbetween catalog loci\n(-n)'))+
  facet_grid(Sample~m,scales='free')

ggsave('/media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full_trimmed/no_filter/cov/cov_diff.png',width=12,height=18)

df2.cov<-df %>%
  group_by(Sample)%>%
  summarize(Coverage=mean(AvCov))

Plot<-ggplot(df2.cov, aes(x=as.factor(Sample), y = Coverage)) +
  geom_bar(stat ='identity')+
  theme_bw()+
  xlab('Sample Name')

ggsave('/media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full_trimmed/no_filter/cov/cov_av.png',width=8,height=4)


