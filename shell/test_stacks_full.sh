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

## without SNP and coverage filter

sh /media/inter/mkapun/projects/Trochilus_ddRAD/shell/summarize_analyses.sh \
  /media/inter/mkapun/projects/Trochilus_ddRAD/results/full \
  /media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full/no_filter \
  1 \
  1

sh /media/inter/mkapun/projects/Trochilus_ddRAD/shell/summarize_analyses.sh \
  /media/inter/mkapun/projects/Trochilus_ddRAD/results/full \
  /media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full/snp095 \
  0.95 \
  1


sh /media/inter/mkapun/projects/Trochilus_ddRAD/shell/summarize_analyses.sh \
  /media/inter/mkapun/projects/Trochilus_ddRAD/results/full \
  /media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full/snp09 \
  0.9 \
  1

sh /media/inter/mkapun/projects/Trochilus_ddRAD/shell/summarize_analyses.sh \
  /media/inter/mkapun/projects/Trochilus_ddRAD/results/full \
  /media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full/cov095 \
  1 \
  0.95


sh /media/inter/mkapun/projects/Trochilus_ddRAD/shell/summarize_analyses.sh \
  /media/inter/mkapun/projects/Trochilus_ddRAD/results/full \
  /media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full/cov09 \
  1 \
  0.9

sh /media/inter/mkapun/projects/Trochilus_ddRAD/shell/summarize_analyses.sh \
  /media/inter/mkapun/projects/Trochilus_ddRAD/results/full \
  /media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full/snp09_cov09 \
  0.9 \
  0.9

sh /media/inter/mkapun/projects/Trochilus_ddRAD/shell/summarize_analyses.sh \
  /media/inter/mkapun/projects/Trochilus_ddRAD/results/full \
  /media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full/snp095_cov095 \
  0.95 \
  0.95
