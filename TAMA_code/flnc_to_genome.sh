#Convert flnc.bam file to fasta
samtools fasta -@ 24 $bam > flnc.$gen.fa

#Mapping flnc reads to genome
minimap2 -ax splice -uf --secondary=no --splice-flank=no -t 24 -C5 -O6,24 -B4 ms.fa flnc.fa | samtools view -@ 12 -b - > flnc.aligned.$gen.bam

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
python2 python2 tama/tama/tama_merge.py -f file_merge.txt -p final
