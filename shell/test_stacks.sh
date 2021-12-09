## test STACKs de-novo pipeline

mkdir /media/inter/mkapun/projects/Trochulus_ddRAD/results/test_stacks

## run ustacks on all individuals

module load NGSmapper/stacks-2.59

j=0
for i in /media/inter/mkapun/projects/Trochulus_ddRAD/data/trimmed/*.1*.gz

do
  j=$((++j))

  ## extract ID of sample
  tmp=${i##*/}
  ID=${tmp%%.*}

  echo $ID

  ustacks \
    -t gzfastq \
    -f /media/inter/mkapun/projects/Trochulus_ddRAD/data/raw/${ID}.1.fq.gz \
    -o /media/inter/mkapun/projects/Trochulus_ddRAD/results/test_stacks -i $j \
    --name $ID \
    -p 2 &

done

wait

cstacks -n 6 \
  -P /media/inter/mkapun/projects/Trochulus_ddRAD/results/test_stacks \
  -M /media/inter/mkapun/projects/Trochulus_ddRAD/popmap_clade.tsv \
  -p 200

sstacks -P /media/inter/mkapun/projects/Trochulus_ddRAD/results/test_stacks \
  -M /media/inter/mkapun/projects/Trochulus_ddRAD/popmap_clade.tsv \
  -p 8

tsv2bam -P /media/inter/mkapun/projects/Trochulus_ddRAD/results/test_stacks \
  -M /media/inter/mkapun/projects/Trochulus_ddRAD/popmap_clade.tsv \
  --pe-reads-dir /media/inter/mkapun/projects/Trochulus_ddRAD/data/raw \
  -t 8

### and now test parameters on subset of lines
while IFS=$'\t' read -r name pop

do
  cp /media/inter/mkapun/projects/Trochulus_ddRAD/data/raw/$name.*.gz /media/inter/mkapun/projects/Trochulus_ddRAD/data/test_raw
done < /media/inter/mkapun/projects/Trochulus_ddRAD/data/popmap_test_all_clades.tsv


## now test parameter space
for m in 3 4 5 6 7

do

  for M in 1 2 3 4 5 6 7 8

  do

    for n in 1 2 3 4 5 6 7 8

    do


      mkdir /media/inter/mkapun/projects/Trochulus_ddRAD/results/test_stacks_${m}_${M}_${n}

      ## run ustacks on all individuals

      j=0
      for i in /media/inter/mkapun/projects/Trochulus_ddRAD/data/test_raw/*.1*.gz

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
          -f /media/inter/mkapun/projects/Trochulus_ddRAD/data/test_raw/${ID}.1.fq.gz \
          -o /media/inter/mkapun/projects/Trochulus_ddRAD/results/test_stacks_${m}_${M}_${n} \
          -i $j \
          --name $ID \
          -p 2 &

      done

      wait

      cstacks -n ${n} \
        -P /media/inter/mkapun/projects/Trochulus_ddRAD/results/test_stacks_${m}_${M}_${n} \
        -M /media/inter/mkapun/projects/Trochulus_ddRAD/data/popmap_test_all_clades.tsv \
        -p 200

      sstacks -P /media/inter/mkapun/projects/Trochulus_ddRAD/results/test_stacks_${m}_${M}_${n} \
        -M /media/inter/mkapun/projects/Trochulus_ddRAD/data/popmap_test_all_clades.tsv \
        -p 200

      tsv2bam -P /media/inter/mkapun/projects/Trochulus_ddRAD/results/test_stacks_${m}_${M}_${n} \
        -M /media/inter/mkapun/projects/Trochulus_ddRAD/data/popmap_test_all_clades.tsv \
        --pe-reads-dir /media/inter/mkapun/projects/Trochulus_ddRAD/data/test_raw \
        -t 200

    done

  done

done


## now test parameter space
for m in 5

do

  for M in 1 2 3

  do

    for n in 1 2 3 4 5 6 7 8

    do


      mkdir /media/inter/mkapun/projects/Trochulus_ddRAD/results/test_stacks_${m}_${M}_${n}

      ## run ustacks on all individuals

      j=0
      for i in /media/inter/mkapun/projects/Trochulus_ddRAD/data/test_raw/*.1*.gz

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
          -f /media/inter/mkapun/projects/Trochulus_ddRAD/data/test_raw/${ID}.1.fq.gz \
          -o /media/inter/mkapun/projects/Trochulus_ddRAD/results/test_stacks_${m}_${M}_${n} \
          -i $j \
          --name $ID \
          -p 2 &

      done

      wait

      cstacks -n ${n} \
        -P /media/inter/mkapun/projects/Trochulus_ddRAD/results/test_stacks_${m}_${M}_${n} \
        -M /media/inter/mkapun/projects/Trochulus_ddRAD/data/popmap_test_all_clades.tsv \
        -p 200

      sstacks -P /media/inter/mkapun/projects/Trochulus_ddRAD/results/test_stacks_${m}_${M}_${n} \
        -M /media/inter/mkapun/projects/Trochulus_ddRAD/data/popmap_test_all_clades.tsv \
        -p 200

      tsv2bam -P /media/inter/mkapun/projects/Trochulus_ddRAD/results/test_stacks_${m}_${M}_${n} \
        -M /media/inter/mkapun/projects/Trochulus_ddRAD/data/popmap_test_all_clades.tsv \
        --pe-reads-dir /media/inter/mkapun/projects/Trochulus_ddRAD/data/test_raw \
        -t 200

    done

  done

done
