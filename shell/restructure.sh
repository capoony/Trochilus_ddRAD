###

# create a symbolic link to the FASTQ files in the data folder

ln -s \
  /media/inter/mkapun/projects/Trochilus_ddRAD/data/RAD-Data_Trsp_2017/cleaned \
  /media/inter/mkapun/projects/Trochilus_ddRAD/data/raw

# create a symbolic link to the popmap_clade file in the data folder

ln -s \
  /media/inter/mkapun/projects/Trochilus_ddRAD/data/RAD-Data_Trsp_2017/info/popmap_clade.tsv \
  /media/inter/mkapun/projects/Trochilus_ddRAD/data/popmap_clade.tsv

ln -s \
  /media/inter/mkapun/projects/Trochilus_ddRAD/data/RAD-Data_Trsp_2017/info/popmap_test_all_clades.tsv \
  /media/inter/mkapun/projects/Trochilus_ddRAD/data/popmap_test_all_clades.tsv
