#This entails the script used to annotated the swan genomes
bam=ms2flnc.sorted.bam
target_genome=muteswan.fasta #black swan
ref1=ch.fa
refid1=CH
refanno1=ch.gff #chicken.gff - need to keep only CDS and exon annotations in the gff file. Otherwise throw an error
out=results/flnc-ms
ref2=zf.fa
refid2=ZF
refanno2=zf.gff
ref3=du.fa
refid3=DU
refanno3=du.gff
annoprefix=flnc.ms
jar=GeMoMa-1.7.1.jar

time java -jar $jar CLI GeMoMaPipeline threads=22 t=$target_genome s=own i=$refid1 a=$refanno1 g=$ref1 \
s=own i=${refid2} a=$refanno2 g=$ref2  \
s=own i=$refid3 a=$refanno3 g=$ref3 \
tblastn=false outdir=$out r=MAPPED ERE.s=FR_UNSTRANDED ERE.m=$bam ERE.c=false AnnotationFinalizer.r=NO  \
GeMoMa.e=0.00001 d=DENOISE DenoiseIntrons.m=50000 #restart=true


