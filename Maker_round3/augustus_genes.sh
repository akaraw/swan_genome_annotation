
####Thousand genes
awk -v OFS="\t" '{ if ($3 == "mRNA") print $1, $4, $5 }' bs_rnd2.all.maker.noseq.gff |awk -v OFS="\t" '{ if ($2 < 1000) print $1, "0", $3+1000; else print $1, $2-1000, $3+1000 }' | \
bedtools getfasta -fi ../blackswan.fasta -bed - -fo bs_rnd2.all.maker.transcripts1000.fasta

