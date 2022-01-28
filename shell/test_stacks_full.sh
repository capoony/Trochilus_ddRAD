## test STACKs de-novo pipeline

mkdir /media/inter/mkapun/projects/Trochilus_ddRAD/results/test_stacks

## run ustacks on all individuals

module load NGSmapper/stacks-2.59

j=0
for i in /media/inter/mkapun/projects/Trochilus_ddRAD/data/trimmed/*.1*.gz

do
  j=$((++j))

  ## extract ID of sample
  tmp=${i##*/}
  ID=${tmp%%.*}

  echo $ID

  ustacks \
    -t gzfastq \
    -f /media/inter/mkapun/projects/Trochilus_ddRAD/data/raw/${ID}.1.fq.gz \
    -o /media/inter/mkapun/projects/Trochilus_ddRAD/results/test_stacks -i $j \
    --name $ID \
    -p 2 &

done

wait

cstacks -n 6 \
  -P /media/inter/mkapun/projects/Trochilus_ddRAD/results/test_stacks \
  -M /media/inter/mkapun/projects/Trochilus_ddRAD/popmap_clade.tsv \
  -p 200

sstacks -P /media/inter/mkapun/projects/Trochilus_ddRAD/results/test_stacks \
  -M /media/inter/mkapun/projects/Trochilus_ddRAD/popmap_clade.tsv \
  -p 8

tsv2bam -P /media/inter/mkapun/projects/Trochilus_ddRAD/results/test_stacks \
  -M /media/inter/mkapun/projects/Trochilus_ddRAD/popmap_clade.tsv \
  --pe-reads-dir /media/inter/mkapun/projects/Trochilus_ddRAD/data/raw \
  -t 8

### and now test parameters on subset of lines
while IFS=$'\t' read -r name pop

do
  cp /media/inter/mkapun/projects/Trochilus_ddRAD/data/raw/$name.*.gz /media/inter/mkapun/projects/Trochilus_ddRAD/data/test_raw
done < /media/inter/mkapun/projects/Trochilus_ddRAD/data/popmap_test_all_clades.tsv

mkdir /media/inter/mkapun/projects/Trochilus_ddRAD/results/full
mkdir /media/inter/mkapun/projects/Trochilus_ddRAD/shell/stacks_full
## now test parameter space
for m in 3 4 5 6 7

do

  for M in 1 2 3 4 5 6 7 8 10 12 15 16 20 30

  do

    for n in 1 2 3 4 5 6 7 8 10 12 15 16 20 30

    do

      echo """

      #!/bin/sh

      ## name of Job
      #PBS -N stacks_${m}_${M}_${n}

      ## Redirect output stream to this file.
      #PBS -o /media/inter/mkapun/projects/Trochilus_ddRAD/results/test_stacks_${m}_${M}_${n}/log.txt

      ## Stream Standard Output AND Standard Error to outputfile (see above)
      #PBS -j oe

      ## Select a maximum of 200 cores and 400gb of RAM
      #PBS -l select=1:ncpus=50:mem=200gb

      ######## load dependencies

      module load NGSmapper/stacks-2.59

      ######## run analyses

      mkdir /media/inter/mkapun/projects/Trochilus_ddRAD/results/test_stacks_${m}_${M}_${n}

      ## run ustacks on all individuals

      j=0
      for i in /media/inter/mkapun/projects/Trochilus_ddRAD/data/test_raw/*.1*.gz

      do
        j=\$((++j))

        ## extract ID of sample
        tmp=\${i##*/}
        ID=\${tmp%%.*}

        ustacks \
          -t gzfastq \
          -m ${m} \
          -M ${M} \
          -f /media/inter/mkapun/projects/Trochilus_ddRAD/data/test_raw/\${ID}.1.fq.gz \
          -o /media/inter/mkapun/projects/Trochilus_ddRAD/results/full/test_stacks_${m}_${M}_${n} \
          -i \${j} \
          --name \${ID} \
          -p 2 &

      done

      wait

      cstacks -n ${n} \
        -P /media/inter/mkapun/projects/Trochilus_ddRAD/results/full/test_stacks_${m}_${M}_${n} \
        -M /media/inter/mkapun/projects/Trochilus_ddRAD/data/popmap_test_all_clades.tsv \
        -p 50

      sstacks -P /media/inter/mkapun/projects/Trochilus_ddRAD/results/full/test_stacks_${m}_${M}_${n} \
        -M /media/inter/mkapun/projects/Trochilus_ddRAD/data/popmap_test_all_clades.tsv \
        -p 50

      tsv2bam -P /media/inter/mkapun/projects/Trochilus_ddRAD/results/full/test_stacks_${m}_${M}_${n} \
        -M /media/inter/mkapun/projects/Trochilus_ddRAD/data/popmap_test_all_clades.tsv \
        --pe-reads-dir /media/inter/mkapun/projects/Trochilus_ddRAD/data/test_raw \
        -t 50

      gstacks -P /media/inter/mkapun/projects/Trochilus_ddRAD/results/full/test_stacks_${m}_${M}_${n} \
        -M /media/inter/mkapun/projects/Trochilus_ddRAD/data/popmap_test_all_clades.tsv \
        -t 50
      """ > /media/inter/mkapun/projects/Trochilus_ddRAD/shell/stacks_full/qsub_${m}_${M}_${n}.sh

      qsub /media/inter/mkapun/projects/Trochilus_ddRAD/shell/stacks_full/qsub_${m}_${M}_${n}.sh

    done

  done

done

### now summarize the data

mkdir /media/inter/mkapun/projects/Trochilus_ddRAD/shell/test

mkdir /media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full
printf "Name\tPropCovLoci\tNoLoci\tPolymorphic\tPropPolymorphic\tAvSNPCount\tSDSNPCount\tAvSNPdensity\tSDSNPdenisty\tAvHet\tSDHet\tCummNoLoci\tCummPolymorphic\tCummPropPolymorphic\tCummAvSNPCount\tCummSDSNPCount\tCummAvSNPdensity\tCummSDSNPdenisty\tCummAvHet\tCummSDHet\n" > /media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full/summary_stats.txt

printf "Name\tPropCovLoci\tPoly\tSample\tAvCov\tSDCov\n" > /media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full/summary_cov.txt

for m in 3 4 5 6 7

do

  for M in 1 2 3 4 5 6 7 8 10 12 15 16 20 30

  do

    for n in 1 2 3 4 5 6 7 8 10 12 15 16 20 30

    do

      #echo ${m}_${M}_${n}

      #echo """

      #!/bin/sh

      ## name of Job
      #PBS -N summary_${m}_${M}_${n}

      ## Redirect output stream to this file.
      #PBS -o /media/inter/mkapun/projects/Trochilus_ddRAD/shell/test/${m}_${M}_${n}_log.txt

      ## Stream Standard Output AND Standard Error to outputfile (see above)
      #PBS -j oe

      ## Select a maximum of 200 cores and 400gb of RAM
      #PBS -l select=1:ncpus=1:mem=10gb

      python  /media/inter/mkapun/projects/Trochilus_ddRAD/scripts/parse_catalog.calls.py \
        --input /media/inter/mkapun/projects/Trochilus_ddRAD/results/full/test_stacks_${m}_${M}_${n}/catalog.calls \
        --name ${m}_${M}_${n} \
        --output /media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full/summary_test &

      #""" > /media/inter/mkapun/projects/Trochilus_ddRAD/shell/test/${m}_${M}_${n}.sh

      #qsub /media/inter/mkapun/projects/Trochilus_ddRAD/shell/test/${m}_${M}_${n}.sh
    done

  done

done

PROCS=50       ;       WAIT=0  ;       END=0

# Wait for next thread.
function waitnext
{       # Needs BASH/KSH
  wait "${PIDS[$(( (WAIT++) % PROCS))]}"
}

for m in 3 4 5 6 7

do

  for M in 1 2 3 4 5 6 7 8 10 12 15 16 20 30

  do

    for n in 1 2 3 4 5 6 7 8 10 12 15 16 20 30

    do
      [ "$((END-WAIT))" -ge "$PROCS" ] && waitnext
      python  /media/inter/mkapun/projects/Trochilus_ddRAD/scripts/parse_catalog.calls.py \
        --input /media/inter/mkapun/projects/Trochilus_ddRAD/results/full/test_stacks_${m}_${M}_${n}/catalog.calls \
        --name ${m}_${M}_${n} \
        --output /media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full/summary  &
      PIDS[$(( (END++) % PROCS ))]=$!
    done
  done
done

# wait for ALL remaining processes
wait



mkdir /media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full/stat

echo '''

#dependencies
library(plyr)
library(ggplot2)
library(tidyverse)
library(akima)
library(gridExtra)

df <- read.table("/media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full/summary_stats.txt",header=T)
df1<-df %>%
  #select(Name,i) %>%
  separate(Name,c("m","M","n"),
    sep="_",
    convert=T)%>%
  filter(PropCovLoci %in% c(0.5,0.75,1.0),
  m %in% c(3,5,7),
  M %in% c(1,2, 3, 4, 6, 8, 10, 15, 20, 30),
  n %in% c(1,2, 3, 4, 6, 8, 10, 15, 20, 30))

df1$PropCovLoci<-sub("^","Prop. samples (-R): ",df1$PropCovLoci)
df1$m<-sub("^","Minimum stack depth (-m): ",df1$m)
df1$n<-factor(df1$n)

i="NoLoci"
for (i in c("SNPCount" ,"SNPdensity","Het")){
  AV=paste0("CummAv",i)
  SD=paste0("CummSD",i)
  df1$ymin=df1[[AV]]-df1[[SD]]
  df1$ymax=df1[[AV]]+df1[[SD]]
colors = c("purple","blue","cyan","green","yellow","red")
#create plot
# Plot<-ggplot(df1, aes_string("M", "n", z = i)) +
#   stat_summary_2d(geom = "raster", bins = 30) +
#   scale_fill_gradientn(colours = colors)+
#   theme_bw()+
#   xlab("Distance allowed between stacks (-M)")+
#   guides(fill=guide_legend(title="Distance allowed\nbetween catalog loci\n(-n)"))+
#   ggtitle(i)+
#   facet_grid(PropCovLoci~m)
#
# ggsave(paste0("/media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full/stat/summary_",i,".png"),width=12,height=6)

Plot<-ggplot(df1, aes_string(x="M", y = AV,col="n",fill="n")) +
  geom_line()+
  #geom_ribbon(aes(ymin=ymin,ymax=ymax),alpha=0.1,colour=NA)+
  theme_bw()+
  xlab("Distance allowed between stacks (-M)")+
  guides(col=guide_legend(title="Distance allowed\nbetween catalog loci\n(-n)"))+
  guides(fill=guide_legend(title="Distance allowed\nbetween catalog loci\n(-n)"))+
  facet_grid(PropCovLoci~m)

ggsave(paste0("/media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full/stat/summary_line_",i,".png"),width=12,height=6)

}

### Log-scale for # loci
# Plot<-ggplot(df1, aes_string("M", "n", z = "CummNoLoci")) +
#   stat_summary_2d(geom = "raster", bins = 30) +
#   scale_fill_gradientn(colours = colors, trans="log10")+
#   theme_bw()+
#   guides(fill=guide_legend(title="Distance allowed\nbetween catalog loci\n(-n)"))+
#   ggtitle("CummNoLoci")+
#   facet_grid(PropCovLoci~m)
#
# ggsave("/media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full/stat/summary_CummNoLoci.png",width=12,height=6)

Plot<-ggplot(df1, aes_string(x="M", y = "CummNoLoci",col="n")) +
  geom_line()+
  theme_bw()+
  xlab("Distance allowed between stacks (-M)")+
  guides(col=guide_legend(title="Distance allowed\nbetween catalog loci\n(-n)"))+
  facet_grid(PropCovLoci~m, scales="free")

ggsave("/media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full/stat/summary_line_CummNoLoci.png",width=12,height=6)
''' > /media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full/summary.r

Rscript /media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full/summary.r

mkdir /media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full/cov

echo '''

#dependencies
library(ggplot2)
library(tidyverse)
library(akima)
library(gridExtra)

df <- read.table("/media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full/summary_cov.txt",header=T)

for (j in c(0.5,0.75,1.0)){

  for (i in levels(as.factor(df$Sample))){

    df1<-df %>%
      #select(Name,i) %>%
      separate(Name,c("m","M","n"),sep="_" ,
      convert=T)%>%
      filter(Sample==i,
        PropCovLoci==j,
        m %in% c(3,5,7),
        M %in% c(1,2, 3, 4, 6, 8, 10, 15, 20, 30),
        n %in% c(1,2, 3, 4, 6, 8, 10, 15, 20, 30))
    df1$Poly[df1$Poly==0]<-"Monomorphic"
    df1$Poly[df1$Poly==1]<-"Polymorphic"
    df1$m<-sub("^","Minimum stack depth (-m): ",df1$m)
    df1$n<-factor(df1$n)

    # colors = c("purple","blue","cyan","green","yellow","red")
    # ###
    # Plot<-ggplot(df1, aes_string("M", "n", z = "AvCov")) +
    #   stat_summary_2d(geom = "raster", bins = 30) +
    #   scale_fill_gradientn(colours = colors)+
    #   theme_bw()+
    #   ggtitle(paste0("Average Coverage; PropCovLoci: ",j))+
    #   guides(fill=guide_legend(title="Distance allowed\nbetween catalog loci\n(-n)"))+
    #   facet_grid(Poly~m)
    #
    # ggsave(paste0("/media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full/cov/cov_",i,"_",j,".png"),width=12,height=6)

    Plot<-ggplot(df1, aes_string(x="M", y = "AvCov",col="n")) +
      geom_line()+
      theme_bw()+
      xlab("Distance allowed between stacks (-M)")+
      guides(col=guide_legend(title="Distance allowed\nbetween catalog loci\n(-n)"))+
      facet_grid(Poly~m,scales="free")

    ggsave(paste0("/media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full/cov/cov_line_",i,"_",j,".png"),width=12,height=6)
  }
}

# df$Poly[df$Poly==0]<-"Monomorphic"
# df$Poly[df$Poly==1]<-"Polymorphic"
#
#
# df2<-spread(df, key = Poly, value = AvCov)
# df2.sum<-df2 %>%
#   #select(Name,i) %>%
#   separate(Name,c("m","M","n"),sep="_" ,
#   convert=T)%>%
#   mutate("Monomorphic/Polymorphic"=Monomorphic/Polymorphic)
#
# df2.sum$n<-factor(df2.sum$n)
# df2.sum$m<-sub("^","Minimum stack depth (-m): ",df2.sum$m)
# df2.sum$Sample<-sub("^","Sample name: ",df2.sum$Sample)
#
# Plot<-ggplot(df2.sum, aes_string(x="M", y = "Monomorphic/Polymorphic",col="n")) +
#   geom_line()+
#   theme_bw()+
#   xlab("Distance allowed between stacks (-M)")+
#   guides(col=guide_legend(title="Distance allowed\nbetween catalog loci\n(-n)"))+
#   facet_grid(Sample~m,scales="free")
#
# ggsave("/media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full/cov/cov_diff.png",width=12,height=18)
#
# df2.cov<-df %>%
#   group_by(Sample)%>%
#   summarize(Coverage=mean(AvCov))
#
# Plot<-ggplot(df2.cov, aes(x=as.factor(Sample), y = Coverage)) +
#   geom_bar(stat ="identity")+
#   theme_bw()+
#   xlab("Sample Name")
#
# ggsave("/media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full/cov/cov_av.png",width=8,height=4)

''' > /media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full/summary_cov.r

Rscript /media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full/summary_cov.r

cp -r /media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full ~/winuser
