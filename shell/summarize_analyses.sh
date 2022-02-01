## summarize analyses

input=$1
output=$2
snp=$3
cov=$4

##################################

### prepare output
path=${output%/*}
mkdir ${path}

printf "Name\tPropCovLoci\tNoLoci\tPolymorphic\tPropPolymorphic\tAvSNPCount\tSDSNPCount\tAvSNPdensity\tSDSNPdensity\tAvHet\tSDHet\tCummNoLoci\tCummPolymorphic\tCummPropPolymorphic\tCummAvSNPCount\tCummSDSNPCount\tCummAvSNPdensity\tCummSDSNPdensity\tCummAvHet\tCummSDHet\n" \
  > ${output}_stats.txt

printf "Name\tPropCovLoci\tPoly\tSample\tAvCov\tSDCov\n" \
  > ${output}_cov.txt


### parallelize the analysis with 200 parallel threads
PROCS=200
WAIT=0
END=0

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
      echo "processing "${m}_${M}_${n}
      python  /media/inter/mkapun/projects/Trochilus_ddRAD/scripts/parse_catalog.calls.py \
        --input ${input}/test_stacks_${m}_${M}_${n}/catalog.calls \
        --name ${m}_${M}_${n} \
        --cov ${cov} \
        --snp ${snp} \
        --output ${output} &> /dev/null &
      PIDS[$(( (END++) % PROCS ))]=$!
    done
  done
done

# wait for ALL remaining processes
wait

### visualize the results

sh /media/inter/mkapun/projects/Trochilus_ddRAD/shell/visualize_stats.sh \
  ${output}
