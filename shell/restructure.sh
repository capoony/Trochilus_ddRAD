###

# create a symbolic link to the original command for demultiplexing as done by the company

ln -s \
  /media/inter/mkapun/projects/Trochulus_ddRAD/data/RAD-Data_Trsp_2017/support.igatech.it/sequences-export/639-Kruckenhauser_Naturhistorisches_Museum_Wien/process_radtags_igt.txt \
  /media/inter/mkapun/projects/Trochulus_ddRAD/shell/process_radtags.sh

# create a symbolic link to the FASTQ files in the data folder

ln -s \
  /media/inter/mkapun/projects/Trochulus_ddRAD/data/RAD-Data_Trsp_2017/cleaned \
  /media/inter/mkapun/projects/Trochulus_ddRAD/data/raw

# create a symbolic link to the popmap_clade file in the data folder

ln -s \
  /media/inter/mkapun/projects/Trochulus_ddRAD/data/RAD-Data_Trsp_2017/info/popmap_clade.tsv \
  /media/inter/mkapun/projects/Trochulus_ddRAD/data/popmap_clade.tsv

ln -s \
  /media/inter/mkapun/projects/Trochulus_ddRAD/data/RAD-Data_Trsp_2017/info/popmap_test_all_clades.tsv \
  /media/inter/mkapun/projects/Trochulus_ddRAD/data/popmap_test_all_clades.tsv

ln -s \
  /media/inter/mkapun/projects/Trochilus_ddRAD/data/RAD-Data_Trsp_2017/info/popmap_test_ohneore.tsv \
  /media/inter/mkapun/projects/Trochilus_ddRAD/data/popmap_test_ohneore.tsv

ln -s \
  /media/inter/mkapun/projects/Trochilus_ddRAD/data/RAD-Data_Trsp_2017/info/popmap_test_ingroup.tsv \
  /media/inter/mkapun/projects/Trochilus_ddRAD/data/popmap_test_ingroup.tsv
