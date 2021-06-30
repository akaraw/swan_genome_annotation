wget https://v101.orthodb.org/download/odb10v1_all_og_fasta.tab.gz && gunzip *.gz
mv odb10v1_all_og_fasta.tab orthos.aa
#with proteins from orthodb train genemark (takes maximum 64 threads)
##first Cluster using mmseqs2 at 90% coverage and 90% identity:
mmseqs createdb orthos.aa proteins_mmseqs
mmseqs cluster --cov-mode 1 -c 0.9 --min-seq-id 0.9 proteins_mmseqs cluster $PWD
mmseqs result2flat proteins_mmseqs proteins_mmseqs cluster cluster_out --use-fasta-header
grep "^>" cluster_out | sed 's/>//g' | seqtk subseq orthos.aa - | seqkit seq -m 10 > uniq_90_proteins.fasta
mkdir proteins && mv orthos.aa uniq_90_proteins.fasta proteins

##predict now
#Installing GeneMark
#http://exon.gatech.edu/GeneMark/
#Install perl modules
mamba create -n evm -c bioconda diamond evidencemodeller splan 
export PATH=/30days/uqakaraw/blackswan_final_anno/evm/gmes_linux_64/:$PATH
export PATH=/30days/uqakaraw/blackswan_final_anno/evm/gmes_linux_64/ProtHint/bin:$PATH
mamba  install -c bioconda perl-yaml perl-math-utils perl-mce perl-parallel-forkmanager perl-hash-merge 
mamba install -c bioconda pasa

Launch_PASA_pipeline.pl \
--CPU 16 -C -R --ALIGNER gmap,blat -g bs.fa -t bs_transcripts.fa -c alignAssembly.conf -u bs_transcripts.fa

create_weights_file.pl -T evm/pasa/annot.sqlite3.pasa_assemblies.gff3 -P pubgemo.gff -A rnd_1_2_3_merged.gff > weights.txt

partition_EVM_inputs.pl --genome BS_postgapfiller.fa --gene_predictions rnd_1_2_3_merged.gff --transcript_alignments annot.sqlite3.pasa_assemblies.gff3 \
--protein_alignments pubgemo.gff --segmentSize 1000000 --overlapSize 10000 --partition_listing partitions_list.out

write_EVM_commands.pl --genome BS_postgapfiller.fa --weights `pwd`/weights.txt --gene_predictions rnd_1_2_3_merged.gff --protein_alignments pubgemo.gff \
--transcript_alignments annot.sqlite3.pasa_assemblies.gff3 --output_file_name evm.out  --partition partitions_list.out >  commands.list

cat commands.list | parallel -j24

recombine_EVM_partial_outputs.pl --partitions partitions_list.out --output_file_name evm.out

convert_EVM_outputs_to_GFF3.pl  --partitions partitions_list.out --output evm.out  --genome BS_postgapfiller.fa

find . -regex ".*evm.out.gff3" -exec cat {} \; > EVM.gff3

gff3_file_fix_CDS_phases.pl EVM.gff3 genome.fasta.masked > fixed.EVM.gff3

python2.7 genomeannotation-GAG-997e384/gag.py -f genome.fasta -g fixed.EVM.gff3



