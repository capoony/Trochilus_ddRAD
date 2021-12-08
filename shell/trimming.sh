## trim reads

mkdir /media/inter/mkapun/projects/Trochilus_ddRAD/data/trimmed

echo '''

#!/bin/sh

## name of Job
#PBS -N trim_galore

## Redirect output stream to this file.
#PBS -o /media/inter/mkapun/projects/Trochilus_ddRAD/log/trimgalore.txt

## Stream Standard Output AND Standard Error to outputfile (see above)
#PBS -j oe

## Select a maximum of 200 cores and 1000gb of RAM
#PBS -l select=1:ncpus=100:mem=100g

######## load dependencies #######

source /opt/anaconda3/etc/profile.d/conda.sh
conda activate trim-galore-0.6.2

## Go to output folder
cd /media/inter/mkapun/projects/Trochilus_ddRAD/data/trimmed

## loop through all FASTQ pairs and trim by quality PHRED 20
for i in ../raw/*.fq.gz

do

  ## extract ID of sample
  tmp=${i##*/}
  ID=${tmp%%.*}

  echo $ID

  trim_galore \
    --paired \
    --quality 20 \
    --length 85  \
    --cores 100 \
    ../raw/${ID}.1.fq.gz \
    ../raw/${ID}.2.fq.gz

done

''' > /media/inter/mkapun/projects/Trochilus_ddRAD/shell/qsub_trimgalore.sh

qsub /media/inter/mkapun/projects/Trochilus_ddRAD/shell/qsub_trimgalore.sh

## move reports to new folder
mkdir /media/inter/mkapun/projects/Trochilus_ddRAD/data/trimmed_reports

mv /media/inter/mkapun/projects/Trochilus_ddRAD/data/trimmed/*.txt /media/inter/mkapun/projects/Trochilus_ddRAD/data/trimmed_reports

## rename trimmed reads to match Stacks requirements
for i in /media/inter/mkapun/projects/Trochilus_ddRAD/data/trimmed/*

do

  tmp=${i%_val*}
  mv $i ${tmp}.fq.gz

done
