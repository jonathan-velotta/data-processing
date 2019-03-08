#!/bin/bash

## This script is used to quality filter and trim poly g tails. It can process both paired end and single end data. 
SAMPLELIST=$1 # Path to a list of prefixes of the raw fastq files. It should be a subset of the the 1st column of the sample table. An example of such a sample list is /workdir/cod/greenland-cod/sample_lists/sample_list_pe_1.tsv
SAMPLETABLE=$2 # Path to a sample table where the 1st column is the prefix of the raw fastq files. The 4th column is the sample ID, the 2nd column is the lane number, and the 3rd column is sequence ID. The combination of these three columns have to be unique. An example of such a sample table is: /workdir/cod/greenland-cod/sample_lists/sample_table_pe.tsv
BASEDIR=$3 # Path to the base directory where adapter clipped fastq file are stored in a subdirectory titled "adapter_clipped" and into which output files will be written to separate subdirectories. An example for the Greenland cod data is: /workdir/cod/greenland-cod
DATATYPE=$4 # Data type. pe for paired end data and se for single end data. 

## Loop over each sample
for SAMPLEFILE in `cat $SAMPLELIST`; do

## Extract relevant values from a table of sample, sequencing, and lane ID (here in columns 4, 3, 2, respectively) for each sequenced library
SAMPLE_ID=`grep -P "${SAMPLEFILE}\t" $SAMPLETABLE | cut -f 4`
SEQ_ID=`grep -P "${SAMPLEFILE}\t" $SAMPLETABLE | cut -f 3`
LANE_ID=`grep -P "${SAMPLEFILE}\t" $SAMPLETABLE | cut -f 2`
SAMPLE_SEQ_ID=$SAMPLE_ID'_'$SEQ_ID'_'$LANE_ID

## The input and output path and file prefix
SAMPLEADAPT=$BASEDIR'adapter_clipped/'$SAMPLE_SEQ_ID
SAMPLEQUAL=$BASEDIR'qual_filtered/'$SAMPLE_SEQ_ID

## Trim polyg tail with fastp. Can also do quality and length trimming.
# -Q disables quality filter, -L disables length filter, -A disables adapter trimming
# Go to https://github.com/OpenGene/fastp for more information
if [ $DATATYPE = pe ]; then
/programs/fastp/fastp --trim_poly_g -Q -L -A -i $SAMPLEADAPT'_adapter_clipped_f_paired.fastq.gz' -I $SAMPLEADAPT'_adapter_clipped_r_paired.fastq.gz' -o $SAMPLEQUAL'_adapter_clipped_qual_filtered_f_paired.fastq.gz' -O $SAMPLEQUAL'_adapter_clipped_qual_filtered_r_paired.fastq.gz'

else [ $DATATYPE = se ]
#/programs/fastp/fastp --trim_poly_g -Q -L -A -i $SAMPLEADAPT'_adapter_clipped_se.fastq.gz' -o $SAMPLEQUAL'_adapter_clipped_qual_filtered_se.fastq.gz' 

fi

done