# !/bin/bash

export NUM_THREADS=8
export BWA_OUTPUT=/projects/micb405/project1/Team4/project2/bwa_output
export METAT_READS=/projects/micb405/project2/SaanichInlet_135m/MetaT_reads/7724.2.82074.AGTCAA.qtrim.3ptrim.artifact.rRNA.clean.fastq.gz
s="${1##*/}"
export FILENAME=${s%.ffn*}

if [ $# -lt 1 ]
then
    echo "Please provide 1 arg. The first arg is the absolute path to the MAG ffn file"
    exit 1
fi

bwa mem -t $NUM_THREADS -p $1 $METAT_READS | gzip -3 > "${BWA_OUTPUT}/${FILENAME}.sam.gz"
