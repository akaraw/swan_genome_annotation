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


