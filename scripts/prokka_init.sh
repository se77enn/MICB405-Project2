# !/bin/bash

export MAGS_DIR=$1 # Absolute Path to read the mags from
export SUFFIX_FLAG=$2 # supplied argument for suffix indicating if high, medium, or low quality of MAGs
export KINGDOM_FLAG=$3 # supplied argument to indicate if the kingdom is Archaea|Bacteria|Mitochondria|Viruses

if [ $# -lt 3 ]
then
    echo "Please provide at three arguments. 1st arg is the absolute path to the directory to read the mags from. 2nd arg is the quality of the mags high|medium|low. 3rd arg is the \
    kingdom Archaea|Bacteria|Mitochondria|Viruses"
    exit 1
fi

function prokaFun {
    s=${1##*/}
    FILENAME=${s%.fa}
    prokka \
    --outdir "${FILENAME}_${KINGDOM_FLAG}_${SUFFIX_FLAG}" \
    --prefix "${FILENAME}_${KINGDOM_FLAG}_${SUFFIX_FLAG}" \
    --kingdom $2 \
    --cpus 4 \
    $1
}

for fa_file in $MAGS_DIR/*.fa; do
    prokaFun $fa_file $KINGDOM_FLAG
done
