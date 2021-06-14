gen=bs #ms
#We merged the annotations from Gemoma, Maker and NCBI/Ensembl with AGAT
agat_sp_merge_annotations.pl -f {gen}_ncbi.final.gff -f gemoma.gff rnd_1_2_3_merged.gff -o ${gen}_final.gff #-f bs_ens.final.gff
#Extract aa sequences
agat_sp_extract_sequecnes.pl =p --cfs --cis -f ${gen}.fasta -g ${gen}_final.gff -o ${gen}.aa

#Create a non-redundant set of proteins with Augustus tool:
aa2nonred.pl --cores=24 --verbosity=5 ${gen}.aa ${gen}.nr.aa

#Assigining a name based on homology
module load blast
mkdir -p blastp
if [ ! -f 'blastp/uniprot_sprot.fasta.gz']
then
wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz
else
echo "uniprot is already downloaded"
fi

#Uniprot matches
blastp -evalue 0.000001 -db blastp/uniprot_sprot.fasta -num_alignments 1 -num_threads 24 -outfmt 6 -max_hsps 1 -out blastp/${gen}.nr.uniprot.txt -query ${gen}.nr.aa

#Interproscan
interproscan.sh -d interpro_nr/ -pa KEGG -iprlookup -cpu 24 -T ${TMPDIR} \
-dra -appl TIGRFAM,ProSiteProfiles,SUPERFAMILY,PANTHER,PFAM -goterms -f tsv -i ${gen}.nr.aa 2>&1 | tee interpro.log
#results will be in interpro_nr/${gen}.nr.aa.tsv, using this we parse the results to the above gff
agat_sp_manage_functional_annotation.pl -f ${gen}_final.gff -i interpro/${gen}.longest.aa.tsv --id cyatratus --output interpro.${gen}.gff
#The results will be in the directory called 'interpro.${gen}.gff', what we need is ${gen}_final.gff in this didrectory
agat_sp_manage_functional_annotation.pl -f interpro.${gen}.gff/${gen}_final.gff -b blastp/${gen}.nr.uniprot.txt --db \
blastp/uniprot_sprot.fasta | tee ${gen}.interpro.uniprot.final.gff

