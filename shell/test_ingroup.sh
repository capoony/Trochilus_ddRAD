
mkdir /media/inter/mkapun/projects/Trochilus_ddRAD/data/test_raw_ingroup

### and now test parameters on subset of lines
while IFS=$'\t' read -r name pop

do
  cp /media/inter/mkapun/projects/Trochilus_ddRAD/data/raw/$name.*.gz /media/inter/mkapun/projects/Trochilus_ddRAD/data/test_raw_ingroup
done < /media/inter/mkapun/projects/Trochilus_ddRAD/data/popmap_test_ingroup.tsv

mkdir /media/inter/mkapun/projects/Trochilus_ddRAD/shell/stacks_ingroup

mkdir /media/inter/mkapun/projects/Trochilus_ddRAD/results/ingroup

## now test parameter space

for m in 3 5 7

do

  for M in 1 2 3 4 6 8 10 15 20 30 #

  do

    for n in 1 2 3 4 6 8 10 15 20 30

    do

      echo """

      #!/bin/sh

      ## name of Job
      #PBS -N stacks_${m}_${M}_${n}

      ## Redirect output stream to this file.
      #PBS -o /media/inter/mkapun/projects/Trochilus_ddRAD/results/ingroup/test_stacks_${m}_${M}_${n}/log.txt

      ## Stream Standard Output AND Standard Error to outputfile (see above)
      #PBS -j oe

      ## Select a maximum of 200 cores and 400gb of RAM
      #PBS -l select=1:ncpus=50:mem=200gb

      ######## load dependencies

      module load NGSmapper/stacks-2.59

      ######## run analyses

      mkdir /media/inter/mkapun/projects/Trochilus_ddRAD/results/ingroup/test_stacks_${m}_${M}_${n}

      ## run ustacks on all individuals

      j=0
      for i in /media/inter/mkapun/projects/Trochilus_ddRAD/data/test_raw_ingroup/*.1*.gz

      do
        j=\$((++j))

        ## extract ID of sample
        tmp=\${i##*/}
        ID=\${tmp%%.*}

        ustacks \
          -t gzfastq \
          -m ${m} \
          -M ${M} \
          -f /media/inter/mkapun/projects/Trochilus_ddRAD/data/test_raw_ingroup/\${ID}.1.fq.gz \
          -o /media/inter/mkapun/projects/Trochilus_ddRAD/results/ingroup/test_stacks_${m}_${M}_${n} \
          -i \${j} \
          --name \${ID} \
          -p 2 &

      done

      wait

      cstacks -n ${n} \
        -P /media/inter/mkapun/projects/Trochilus_ddRAD/results/ingroup/test_stacks_${m}_${M}_${n} \
        -M /media/inter/mkapun/projects/Trochilus_ddRAD/data/popmap_test_ingroup.tsv \
        -p 50

      sstacks -P /media/inter/mkapun/projects/Trochilus_ddRAD/results/ingroup/test_stacks_${m}_${M}_${n} \
        -M /media/inter/mkapun/projects/Trochilus_ddRAD/data/popmap_test_ingroup.tsv \
        -p 50

      tsv2bam -P /media/inter/mkapun/projects/Trochilus_ddRAD/results/ingroup/test_stacks_${m}_${M}_${n} \
        -M /media/inter/mkapun/projects/Trochilus_ddRAD/data/popmap_test_ingroup.tsv \
        --pe-reads-dir /media/inter/mkapun/projects/Trochilus_ddRAD/data/test_raw_ingroup \
        -t 50

      gstacks -P /media/inter/mkapun/projects/Trochilus_ddRAD/results/ingroup/test_stacks_${m}_${M}_${n} \
        -M /media/inter/mkapun/projects/Trochilus_ddRAD/data/popmap_test_ingroup.tsv \
        -t 50
      """ > /media/inter/mkapun/projects/Trochilus_ddRAD/shell/stacks_ingroup/qsub_${m}_${M}_${n}.sh

      qsub /media/inter/mkapun/projects/Trochilus_ddRAD/shell/stacks_ingroup/qsub_${m}_${M}_${n}.sh

    done

  done

done
#
#
# ### now summarize the data

mkdir /media/inter/mkapun/projects/Trochilus_ddRAD/shell/test/ingroup/

mkdir /media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/ingroup
printf "Name\tPropCovLoci\tNoLoci\tPolymorphic\tPropPolymorphic\tAvSNPCount\tSDSNPCount\tAvSNPdensity\tSDSNPdenisty\tCummNoLoci\tCummPolymorphic\tCummPropPolymorphic\tCummAvSNPCount\tCummSDSNPCount\tCummAvSNPdensity\tCummSDSNPdenisty\n" > /media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/ingroup/summary_stats.txt

printf "Name\tPropCovLoci\tPoly\tSample\tAvCov\tSDCov\n" > /media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/ingroup/summary_cov.txt

for m in 3 5 7

do

  for M in 10 15 20 30 1 2 3 4 6 8

  do

    for n in 1 2 3 4 6 8 10 15 20 30

    do

      #echo ${m}_${M}_${n}

      #echo """

      #!/bin/sh

      ## name of Job
      #PBS -N summary_${m}_${M}_${n}

      ## Redirect output stream to this file.
      #PBS -o /media/inter/mkapun/projects/Trochilus_ddRAD/shell/test/ingroup/${m}_${M}_${n}_log.txt

      ## Stream Standard Output AND Standard Error to outputfile (see above)
      #PBS -j oe

      ## Select a maximum of 200 cores and 400gb of RAM
      #PBS -l select=1:ncpus=1:mem=10gb

      python  /media/inter/mkapun/projects/Trochilus_ddRAD/scripts/parse_catalog.calls.py \
        --input /media/inter/mkapun/projects/Trochilus_ddRAD/results/ingroup/test_stacks_${m}_${M}_${n}/catalog.calls \
        --name ${m}_${M}_${n} \
        --output /media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/ingroup/summary &

      #""" > /media/inter/mkapun/projects/Trochilus_ddRAD/shell/test/ingroup/${m}_${M}_${n}.sh

      #qsub /media/inter/mkapun/projects/Trochilus_ddRAD/shell/test/ingroup/${m}_${M}_${n}.sh
    done

  done

done


mkdir /media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/ingroup/stat

echo '''

#dependencies
library(plyr)
library(ggplot2)
library(tidyverse)
library(akima)
library(gridExtra)

df <- read.table("/media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/ingroup/summary_stats.txt",header=T)
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

ggsave(paste0("/media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/ingroup/stat/summary_",i,".png"),width=12,height=6)

Plot<-ggplot(df1, aes_string(x="M", y = i,col="n")) +
  geom_line()+
  theme_bw()+
  xlab("Distance allowed between stacks (-M)")+
  guides(col=guide_legend(title="Distance allowed\nbetween catalog loci\n(-n)"))+
  facet_grid(PropCovLoci~m)

ggsave(paste0("/media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/ingroup/stat/summary_line_",i,".png"),width=12,height=6)

}

### Log-scale for # loci
Plot<-ggplot(df1, aes_string("M", "n", z = "CummNoLoci")) +
  stat_summary_2d(geom = "raster", bins = 30) +
  scale_fill_gradientn(colours = colors, trans="log10")+
  theme_bw()+
  guides(fill=guide_legend(title="Distance allowed\nbetween catalog loci\n(-n)"))+
  ggtitle("CummNoLoci")+
  facet_grid(PropCovLoci~m)

ggsave("/media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/ingroup/stat/summary_CummNoLoci.png",width=12,height=6)

Plot<-ggplot(df1, aes_string(x="M", y = "CummNoLoci",col="n")) +
  geom_line()+
  theme_bw()+
  xlab("Distance allowed between stacks (-M)")+
  guides(col=guide_legend(title="Distance allowed\nbetween catalog loci\n(-n)"))+
  facet_grid(PropCovLoci~m, scales="free")

ggsave("/media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/ingroup/stat/summary_line_CummNoLoci.png",width=12,height=6)
''' > /media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/ingroup/summary.r

Rscript /media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/ingroup/summary.r
