#Creating confident gene model for SNAP base de novo gene preditction
#in the mute swan working directory:
gen=ms #or bs
mkdir -p snap/round1
cd snap/round1
maker2zff -x 0.25 -l 50 -d ../../round1_${gen}.maker.output/round1_${gen}_master_datastore_index.log
rename genome ${gen}_rnd1.zff.length50_aed0.25 *
fathom ${gen}_rnd1.zff.length50_aed0.25.ann ${gen}_rnd1.zff.length50_aed0.25.dna -gene-stats > gene-stats.log 2>&1
fathom ${gen}_rnd1.zff.length50_aed0.25.ann ${gen}_rnd1.zff.length50_aed0.25.dna -validate > validate.log 2>&1
fathom ${gen}_rnd1.zff.length50_aed0.25.ann ${gen}_rnd1.zff.length50_aed0.25.dna -categorize 1000 > categorize.log 2>&1
fathom uni.ann uni.dna -export 1000 -plus > uni-plus.log 2>&1
# create the training parameters
mkdir params
cd params
forge ../export.ann ../export.dna > ../forge.log 2>&1
cd ..
# assembly the HMM
hmm-assembler.pl ${gen}_rnd1.zff.length50_aed0.25 params > ${gen}_rnd1.zff.length50_aed0.25.hmm
