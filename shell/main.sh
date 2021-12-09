###

## assign new group to project folder

groupadd Hygromiidae # make group Hygromiidae
usermod -a -G Hygromiidae mkapun # add users to group
usermod -a -G Hygromiidae lkruckenhauser # add users to group
chgrp -R Hygromiidae /media/inter/mkapun/projects/Trochulus_ddRAD # change group ownership
chmod -R 775 /media/inter/mkapun/projects/Trochulus_ddRAD # add read/write/exceute rights to Group for all folders and subfolders


## store log files

mkdir /media/inter/mkapun/projects/Trochulus_ddRAD/log

## restructure and copy data from Luise's folder

sh /media/inter/mkapun/projects/Trochulus_ddRAD/shell/restructure.sh

## trim raw reads

sh /media/inter/mkapun/projects/Trochulus_ddRAD/shell/trimming.sh
