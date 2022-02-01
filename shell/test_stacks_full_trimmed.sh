## test STACKs de-novo pipeline

mkdir /media/inter/mkapun/projects/Trochilus_ddRAD/data/test_trimmed

### and now test parameters on subset of lines
while IFS=$'\t' read -r name pop

do
  echo $name
  cp /media/inter/mkapun/projects/Trochilus_ddRAD/data/trimmed/${name}.*.gz /media/inter/mkapun/projects/Trochilus_ddRAD/data/test_trimmed
done < /media/inter/mkapun/projects/Trochilus_ddRAD/data/popmap_test_all_clades.tsv

mkdir -p /media/inter/mkapun/projects/Trochilus_ddRAD/results/full_trimmed/log
mkdir /media/inter/mkapun/projects/Trochilus_ddRAD/shell/stacks_full_trimmed
## now test parameter space
for m in 3 5 7

do

  for M in 1 3 6 10 12

  do

    for n in 1 3 6 10 12

    do


      echo """

      #!/bin/sh

      ## name of Job
      #PBS -N stacks_${m}_${M}_${n}

      ## Redirect output stream to this file.
      #PBS -o /media/inter/mkapun/projects/Trochilus_ddRAD/results/full_trimmed/log/${m}_${M}_${n}_log.txt

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
      for i in /media/inter/mkapun/projects/Trochilus_ddRAD/data/test_trimmed/*.1*.gz

      do
        j=\$((++j))

        ## extract ID of sample
        tmp=\${i##*/}
        ID=\${tmp%%.*}

        ustacks \
          -t gzfastq \
          -m ${m} \
          -M ${M} \
          -f /media/inter/mkapun/projects/Trochilus_ddRAD/data/test_trimmed/\${ID}.1.fq.gz \
          -o /media/inter/mkapun/projects/Trochilus_ddRAD/results/full_trimmed/test_stacks_${m}_${M}_${n} \
          -i \${j} \
          --force-diff-len \
          --name \${ID} \
          -p 2 &

      done

      wait

      cstacks -n ${n} \
        -P /media/inter/mkapun/projects/Trochilus_ddRAD/results/full_trimmed/test_stacks_${m}_${M}_${n} \
        -M /media/inter/mkapun/projects/Trochilus_ddRAD/data/popmap_test_all_clades.tsv \
        -p 50

      sstacks -P /media/inter/mkapun/projects/Trochilus_ddRAD/results/full_trimmed/test_stacks_${m}_${M}_${n} \
        -M /media/inter/mkapun/projects/Trochilus_ddRAD/data/popmap_test_all_clades.tsv \
        -p 50

      tsv2bam -P /media/inter/mkapun/projects/Trochilus_ddRAD/results/full_trimmed/test_stacks_${m}_${M}_${n} \
        -M /media/inter/mkapun/projects/Trochilus_ddRAD/data/popmap_test_all_clades.tsv \
        --pe-reads-dir /media/inter/mkapun/projects/Trochilus_ddRAD/data/test_trimmed \
        -t 50

      gstacks -P /media/inter/mkapun/projects/Trochilus_ddRAD/results/full_trimmed/test_stacks_${m}_${M}_${n} \
        -M /media/inter/mkapun/projects/Trochilus_ddRAD/data/popmap_test_all_clades.tsv \
        -t 50
      """ > /media/inter/mkapun/projects/Trochilus_ddRAD/shell/stacks_full_trimmed/qsub_${m}_${M}_${n}.sh

      qsub /media/inter/mkapun/projects/Trochilus_ddRAD/shell/stacks_full_trimmed/qsub_${m}_${M}_${n}.sh

    done

  done

done

### now summarize the data

## without SNP and coverage filter

sh /media/inter/mkapun/projects/Trochilus_ddRAD/shell/summarize_analyses2.sh \
  /media/inter/mkapun/projects/Trochilus_ddRAD/results/full_trimmed \
  /media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full_trimmed/no_filter \
  1 \
  1

sh /media/inter/mkapun/projects/Trochilus_ddRAD/shell/summarize_analyses2.sh \
  /media/inter/mkapun/projects/Trochilus_ddRAD/results/full_trimmed \
  /media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full_trimmed/snp095 \
  0.95 \
  1


sh /media/inter/mkapun/projects/Trochilus_ddRAD/shell/summarize_analyses2.sh \
  /media/inter/mkapun/projects/Trochilus_ddRAD/results/full_trimmed \
  /media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full_trimmed/snp09 \
  0.9 \
  1

sh /media/inter/mkapun/projects/Trochilus_ddRAD/shell/summarize_analyses2.sh \
  /media/inter/mkapun/projects/Trochilus_ddRAD/results/full_trimmed \
  /media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full_trimmed/cov095 \
  1 \
  0.95


sh /media/inter/mkapun/projects/Trochilus_ddRAD/shell/summarize_analyses2.sh \
  /media/inter/mkapun/projects/Trochilus_ddRAD/results/full_trimmed \
  /media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full_trimmed/cov09 \
  1 \
  0.9

sh /media/inter/mkapun/projects/Trochilus_ddRAD/shell/summarize_analyses2.sh \
  /media/inter/mkapun/projects/Trochilus_ddRAD/results/full_trimmed \
  /media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full_trimmed/snp09_cov09 \
  0.9 \
  0.9

sh /media/inter/mkapun/projects/Trochilus_ddRAD/shell/summarize_analyses2.sh \
  /media/inter/mkapun/projects/Trochilus_ddRAD/results/full_trimmed \
  /media/inter/mkapun/projects/Trochilus_ddRAD/results/summary/full_trimmed/snp095_cov095 \
  0.95 \
  0.95
