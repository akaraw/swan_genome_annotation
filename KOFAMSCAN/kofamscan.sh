#kofamscan run:

mamba create -n kofam -c bioconda kofamscan
wget ftp://ftp.genome.jp/pub/db/kofam/ko_list.gz
wget ftp://ftp.genome.jp/pub/db/kofam/profiles.tar.gz

gunzip ko_list.gz
tar xf profiles.tar.gz

exec_annotation -c config.yml -E 0.00001 --tmp-dir ${TMPDIR} -f mapper -o bs.ens.txt bs.ens.faa

