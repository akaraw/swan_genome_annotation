#We merged the annotations from Gemoma, Maker and NCBI/Ensembl with AGAT
agat_sp_merge_annotations.pl -f bs_ens.final.gff -f bs_ncbi.final.gff -f gemoma.gff rnd_1_2_3_merged.gff -o bs_final.gff
#Extract aa sequences

#Create a non-redundant set of proteins with Augustus tool:
aa2nonred.pl --cores=24 --verbosity=5 ${gen}.aa ${gen}.nr.aa
