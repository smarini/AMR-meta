#!/bin/bash

usage() { echo "
********************************************

Usage: $0 

$0 -a FASTQ_R1 -b FASTQ_R2 -o OUT_DIR -p NCORES

        -a	short read R1 file [fastq]
        -b	short read R2 file [fastq]
        -o	output directory, defaults to output
        -p	# of cores for parallel computing, defaults to 1

Singularity:
singularity run amrmeta.sif -a FASTQ_R1 -b FASTQ_R2 -o OUT_DIR -p NCORES

********************************************

        examples of use:
        ./AMR-meta.sh -a data/example/example_R1.fastq \\
                -b data/example/example_R2.fastq \\
                -o output \\
                -p 4
                
        singularity run amrmeta.sif -a data/example/example_R1.fastq \\
                -b data/example/example_R2.fastq \\
                -o output \\
                -p 4
                
********************************************
  " 1>&2; exit 1; }


prog=$(readlink -f $0)
progdir=$(dirname $prog)

# check if R works
command -v Rscript >/dev/null 2>&1 || { echo >&2 "It is not possbile to run Rscript. Please install R."; exit 1;}

# check if needed R packages are installed
Rscript ${progdir}/bin/check_packages.R
if  [ $? == 1 ]; then
  exit 1;
fi

date

# init
p=1; a=""; b=""; o=output

while getopts "a:b:o:p:" opts; do
    case "${opts}" in
        a)
            a=${OPTARG}
            ;;
	b)
            b=${OPTARG}
            ;;
	o)
            o=${OPTARG}
            ;;
	p)
            p=${OPTARG}
            ;;

        *)
            usage
            ;;
    esac
done

prog=$(readlink -f $0)
progdir=$(dirname $prog)

# print recap input files
echo "R1 file = ${a}" >>/dev/stderr
echo "R2 file = ${b}" >>/dev/stderr
echo "output directory = ${o}" >>/dev/stderr
echo "progdir = ${progdir}" >>/dev/stderr

if [ ! -f ${a} ] || [ ! -f ${b} ] || [ -z ${a} ] || [ -z ${b} ]; then
    echo "Cannot proceed. R1 and/or R2 files not present."
    usage
    exit 0
fi

# make sure to remove partial results of old/interrupted runs
if [ -d ${o}/tmp ]; then \rm -rf ${o}/tmp/*; fi

mkdir -p ${o}/tmp

# detect kmers and produce index file
echo "Detecting kmers..." >>/dev/stderr
${progdir}/bin/prep_features ${a} ${b} ${o}/tmp/sparse_features $progdir/data/kmers_per_cpp.txt $progdir/data/kmers_per_cpp_rc.txt

date

echo "Predicting..." >>/dev/stderr

n=$(($(ls ${o}/tmp/ | wc -l)-1))
for chunk in $(seq 0 $p $n); do
  echo "Processing chunk ${chunk}" >>/dev/stderr
  for cpu in $(seq 0 $(($p-1))); do
    if [ -f "${o}/tmp/sparse_features_$(($cpu+$chunk)).csv" ]; then
      Rscript ${progdir}/bin/predict.R ${progdir} ${o}/tmp/sparse_features_$(($cpu+$chunk)).csv ${o} &
    fi
    done
    wait
  done

# remove tmp data
 \rm ${o}/tmp
 cat ${o}/kmer_predictions_*.csv > ${o}/kmer_predictions.csv
 cat ${o}/kmer_predictions_*.csv > ${o}/metaf_predictions.csv
 \rm ${o}/kmer_predictions_*.csv
 \rm ${o}/kmer_predictions_*.csv

date

