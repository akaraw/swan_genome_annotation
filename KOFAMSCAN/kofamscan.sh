#kofamscan run:

mamba create -n kofam -c bioconda kofamscan
wget ftp://ftp.genome.jp/pub/db/kofam/ko_list.gz
wget ftp://ftp.genome.jp/pub/db/kofam/profiles.tar.gz

gunzip ko_list.gz
tar xf profiles.tar.gz

