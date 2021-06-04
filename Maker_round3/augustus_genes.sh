
####Thousand genes
awk -v OFS="\t" '{ if ($3 == "mRNA") print $1, $4, $5 }' bs_rnd2.all.maker.noseq.gff |awk -v OFS="\t" '{ if ($2 < 1000) print $1, "0", $3+1000; else print $1, $2-1000, $3+1000 }' | \
bedtools getfasta -fi ../blackswan.fasta -bed - -fo bs_rnd2.all.maker.transcripts1000.fasta

rsync -av bs_rnd2.all.maker.transcripts1000.fasta ${TMPDIR}
rsync -av /30days/uqakaraw/03.BUSCO/busco_dbs ${TMPDIR}
cd ${TMPDIR}
#rsync -av augustus $PBS_O_WORKDIR

#Define values for future calculations
CPU=20
LINEAGE=aves_odb10
OUTPUT=augustus
TRANS=bs_rnd2.all.maker.transcripts1000.fasta
download_dir=busco_dbs
MODE=genome


#Run busco:
busco -m ${MODE} -i ${TRANS} --augustus --long --augustus_species chicken --augustus_parameters='--progress=true' --offline -o ${OUTPUT} -l ${LINEAGE} --download_path ${download_dir} -c ${CPU} -f
