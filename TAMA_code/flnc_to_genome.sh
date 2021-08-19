#Dependecies TAMA, bedtools, samtools, python2, seqkit, blast+
#Download the mallard proteome from Ensembl version 104 and make a blast database for blastp
#makeblastdb 
#makeblastdb -in Anas_platyrhynchos.fa -dbtype prot -parse_seqids

#Declare your variables
gen= #genome prefix example ms.fa in ms
bam= #flnc bam file from ISOseq3 run with --retain poly-A tail

#Convert flnc.bam file to fasta
samtools fasta -@ 24 $bam > flnc.$gen.fa

#Mapping flnc reads to genome
minimap2 -ax splice -uf --secondary=no --splice-flank=no -t 24 -C5 -O6,24 -B4 ms.fa flnc.$gen.fa | samtools view -@ 12 -b - > flnc.aligned.$gen.bam

#Sorting bam file 
samtools sort -@ 10 -o flnc.sorted.bam flnc.aligned.$gen.bam

#Split bam file into 10 sam files
python2 tama/tama/tama_go/split_files/tama_mapped_sam_splitter.py flnc.sorted.bam 9 ms

#Running TAMA collapse for each sam file with two different settings
for i in ms_*.sam; do base=$(basename $i ".sam"); python2 tama_collapse.py -a 100 -z 100 -x no_cap -sjt 20 -lde 2 -s $i -p ${base}_run2 -f ${gen}.fasta ; done
for i in ms_*.sam; do base=$(basename $i ".sam"); python2 tama_collapse.py -a 100 -z 100 -x no_cap -s $i -p ${base}_run1 -f ${gen}.fasta ; done

#Merging sperate collapse results
python2 python2 tama/tama/tama_merge.py -f file_run1.txt -p firstrun
python2 python2 tama/tama/tama_merge.py -f file_run2.txt -p secondrun
python2 python2 tama/tama/tama_merge.py -f file_final.txt -p final_${gen}

#Get fasta and ORF with seqkit and bedtools
bedtools getfasta -name -split -s -fi ${gen}.fasta -bed final_${gen}.bed -fo ${gen}_iso.fasta
python2 tama/tama/tama_go/orf_nmd_predictions/tama_orf_seeker.py -f ${gen}_iso.fasta -o ${gen}_iso.aa
seqkit seq -m 20 ${gen}_iso.aa > ${gen}_iso.20.aa
seqkit split ms_iso.20.aa -p 100

#Export function
function tama_blast() { n=$(basename "$1" ".fa"); blastp -evalue 1e-10 -db Anas_platyrhynchos.fa -num_threads 1 -max_hsps 1 -out ${n}.txt -query $1; }
export -f tama_blast

#Run blastp in parallel
find ${gen}_iso.20.aa.split/ -type f -name "*aa" | parallel -j 24 tama {}
cat ${gen}_iso.20.part_001.aa.txt > ${gen}_iso.20.txt
cat ${gen}_iso.20.part_{002..100}.aa.txt |tail -n +24 >> ${gen}_iso.20.txt

#Parsing blastp results
python2 tama/tama/tama_go/orf_nmd_predictions/tama_orf_blastp_parser.py -b ${gen}_iso.20.txt -o ${gen}_blastp -f ensembl





