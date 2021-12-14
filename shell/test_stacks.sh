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


## now test parameter space
for m in 3 4 5 6 7

do

  for M in 1 2 3 4 5 6 7 8

  do

    for n in 1 2 3 4 5 6 7 8

    do


      mkdir /media/inter/mkapun/projects/Trochilus_ddRAD/results/test_stacks_${m}_${M}_${n}

      ## run ustacks on all individuals

      j=0
      for i in /media/inter/mkapun/projects/Trochilus_ddRAD/data/test_raw/*.1*.gz

      do
        j=$((++j))

        ## extract ID of sample
        tmp=${i##*/}
        ID=${tmp%%.*}

        echo $ID

        ustacks \
          -t gzfastq \
          -m ${m} \
          -M ${M} \
          -f /media/inter/mkapun/projects/Trochilus_ddRAD/data/test_raw/${ID}.1.fq.gz \
          -o /media/inter/mkapun/projects/Trochilus_ddRAD/results/test_stacks_${m}_${M}_${n} \
          -i $j \
          --name $ID \
          -p 2 &

      done

      wait

      cstacks -n ${n} \
        -P /media/inter/mkapun/projects/Trochilus_ddRAD/results/test_stacks_${m}_${M}_${n} \
        -M /media/inter/mkapun/projects/Trochilus_ddRAD/data/popmap_test_all_clades.tsv \
        -p 200

      sstacks -P /media/inter/mkapun/projects/Trochilus_ddRAD/results/test_stacks_${m}_${M}_${n} \
        -M /media/inter/mkapun/projects/Trochilus_ddRAD/data/popmap_test_all_clades.tsv \
        -p 200

      tsv2bam -P /media/inter/mkapun/projects/Trochilus_ddRAD/results/test_stacks_${m}_${M}_${n} \
        -M /media/inter/mkapun/projects/Trochilus_ddRAD/data/popmap_test_all_clades.tsv \
        --pe-reads-dir /media/inter/mkapun/projects/Trochilus_ddRAD/data/test_raw \
        -t 200

    done

  done

done

# initialize a semaphore with a given number of tokens
open_sem(){
  mkfifo pipe-$$
  exec 3<>pipe-$$
  rm pipe-$$
  local i=
  for((;i>0;i--)); do
    printf %s 000 >&3
  done
}

# run the given command asynchronously and pop/push tokens
run_with_lock(){
  local x
  # this read waits until there is something to read
  read -u 3 -n 3 x && ((0==x)) || exit $x
  (
    ( "$@"; )
    # push the return code of the command to the semaphore
    printf '%.3d' $? >&3
  )&
}


N=50
open_sem $N
## now test parameter space

module load NGSmapper/stacks-2.59

for m in 3 4 5 6 7

do

  for M in 1 2 3 4 5 6 7 8

  do

    for n in 1 2 3 4 5 6 7 8

    do

      gstacks -P /media/inter/mkapun/projects/Trochilus_ddRAD/results/test_stacks_${m}_${M}_${n} \
        -M /media/inter/mkapun/projects/Trochilus_ddRAD/data/popmap_test_all_clades.tsv \
        -t 200
    done

  done

done

### now summarize the data

mkdir /media/inter/mkapun/projects/Trochilus_ddRAD/results/summary
printf "Name\tNoLoci\tPolymorphic\tPropPolymorphic\tAvContigLen\tSDContigLen\tAvSNPCount\tSDSNPCount\tAvSNPdensity\tSDSNPdenisty\n" > /media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/summary.txt
for m in 6 7 #3 4 5 #6 7

do

  for M in 1 2 3 4 5 6 7 8

  do

    for n in 1 2 3 4 5 6 7 8

    do

      echo ${m}_${M}_${n}

      python  /media/inter/mkapun/projects/Trochilus_ddRAD/scripts/parse_catalog.calls.py \
        --input /media/inter/mkapun/projects/Trochilus_ddRAD/results/test_stacks_${m}_${M}_${n}/catalog.calls \
        --name ${m}_${M}_${n} \
        >> /media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/summary.txt
    done

  done

done



echo '''

#dependencies
library(ggplot2)
library(tidyverse)
library(akima)
library(gridExtra)

df <- read.table("/media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/summary.txt",header=T)
df<-df %>%
  #select(Name,i) %>%
  separate(Name,c("m","M","n"),sep="_")
i="NoLoci"
for (i in c("NoLoci","PropPolymorphic","AvContigLen","SDContigLen","AvSNPCount"  ,"SDSNPCount","AvSNPdensity","SDSNPdenisty")){
colors = c("blue","green","yellow","red")
#create plot
Plot<-ggplot(df, aes_string("M", "n", z = i)) +
  stat_summary_2d(geom = "raster", bins = 30) +
  scale_fill_gradientn(colours = colors)+
  theme_bw()+
  #theme(legend.title = element_text("Seconds/read"))+
  ggtitle(i)+
  facet_grid(.~m)

ggsave(paste0("/media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/summary_",i,".png"),width=9,height=3)
}
''' > /media/inter/mkapun/projects/MinION_TestRuns/Basecalling/runtimes.r

Rscript /media/inter/mkapun/projects/MinION_TestRuns/Basecalling/runtimes.r
