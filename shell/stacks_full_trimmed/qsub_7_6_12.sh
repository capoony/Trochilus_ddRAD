

      #!/bin/sh

      ## name of Job
      #PBS -N stacks_7_6_12

      ## Redirect output stream to this file.
      #PBS -o /media/inter/mkapun/projects/Trochilus_ddRAD/results/full_trimmed/log/7_6_12_log.txt

      ## Stream Standard Output AND Standard Error to outputfile (see above)
      #PBS -j oe

      ## Select a maximum of 200 cores and 400gb of RAM
      #PBS -l select=1:ncpus=50:mem=200gb

      ######## load dependencies

      module load NGSmapper/stacks-2.59

      ######## run analyses

      mkdir /media/inter/mkapun/projects/Trochilus_ddRAD/results/test_stacks_7_6_12

      ## run ustacks on all individuals

      j=0
      for i in /media/inter/mkapun/projects/Trochilus_ddRAD/data/test_trimmed/*.1*.gz

      do
        j=$((++j))

        ## extract ID of sample
        tmp=${i##*/}
        ID=${tmp%%.*}

        ustacks           -t gzfastq           -m 7           -M 6           -f /media/inter/mkapun/projects/Trochilus_ddRAD/data/test_trimmed/${ID}.1.fq.gz           -o /media/inter/mkapun/projects/Trochilus_ddRAD/results/full_trimmed/test_stacks_7_6_12           -i ${j}           --force-diff-len           --name ${ID}           -p 2 &

      done

      wait

      cstacks -n 12         -P /media/inter/mkapun/projects/Trochilus_ddRAD/results/full_trimmed/test_stacks_7_6_12         -M /media/inter/mkapun/projects/Trochilus_ddRAD/data/popmap_test_all_clades.tsv         -p 50

      sstacks -P /media/inter/mkapun/projects/Trochilus_ddRAD/results/full_trimmed/test_stacks_7_6_12         -M /media/inter/mkapun/projects/Trochilus_ddRAD/data/popmap_test_all_clades.tsv         -p 50

      tsv2bam -P /media/inter/mkapun/projects/Trochilus_ddRAD/results/full_trimmed/test_stacks_7_6_12         -M /media/inter/mkapun/projects/Trochilus_ddRAD/data/popmap_test_all_clades.tsv         --pe-reads-dir /media/inter/mkapun/projects/Trochilus_ddRAD/data/test_trimmed         -t 50

      gstacks -P /media/inter/mkapun/projects/Trochilus_ddRAD/results/full_trimmed/test_stacks_7_6_12         -M /media/inter/mkapun/projects/Trochilus_ddRAD/data/popmap_test_all_clades.tsv         -t 50
      
