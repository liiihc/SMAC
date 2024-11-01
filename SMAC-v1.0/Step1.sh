#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CPU=1
Passes=20
FragmentSize=50
Identity=80
Coverage=80
input=""
ref=""
cut=50
binnumber=50
name=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -input)
            input="$2"
            shift 2
            ;;
        -ref)
            ref="$2"
            shift 2
            ;;
        -cpu)
            CPU="$2"
            shift 2
            ;;
        -passes)
            Passes="$2"
            shift 2
            ;;
        -fragmentsize)
            FragmentSize="$2"
            shift 2
            ;;
        -identity)
            Identity="$2"
            shift 2
            ;;
	-coverage)
            Coverage="$2"
            shift 2
            ;;
	-cut)
            cut="$2"
            shift 2
            ;;
	-binnumber)
            binnumber="$2"
            shift 2
            ;;
	-name)
	    name="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 -input <input_bam> -name <project_prefix> -ref <reference_fasta> [-cpu <cpu>] [-passes <passes>] [-fragmentsize <size>] [-identity <identity>] [-coverage <coverage>] [-cut <cut>] [-binnumber <bin_number>]"
            echo "Options:"
            echo "  -input         Raw data BAM file (required)"
            echo "  -name          Prefix of output files (required)"
            echo "  -ref           Reference genome FASTA file (required)"
            echo "  -cpu           Number of CPU cores to use (default: 1)"
            echo "  -passes        Min passes per molecule (default: 20)"
            echo "  -fragmentsize  Min fragment size threshold (default: 50)"
            echo "  -identity      Identity threshold (default: 80)"
            echo "  -coverage      Coverage threshold (default: 80)"
	    echo "  -cut  	   Bases flanking molecules will be checked (default: 50)"
            echo "  -binnumber     The bases in the middle of molecules will be united into n bins (default: 50)"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [[ -z "$input" ]]; then
    echo "Error: Raw data BAM file is Missing! Use -input to specify the input BAM file."
    exit 1
fi

if [[ -z "$name" ]]; then
    echo "Error: Prefix of output file is Missing! Use -name to specify the name of your project."
    exit 1
fi

if [[ -z "$ref" ]]; then
    echo "Error: Reference genome FASTA file is Missing! Use -ref to specify the reference FASTA file."
    exit 1
fi


mkdir -p ${name}_all_A_IPD/

samtools sort -@ $CPU -m 4G $input -o ${name}.sorted.bam
ccs -j $CPU --hifi-kinetics ${name}.sorted.bam ${name}.sorted.hifi.bam
samtools view -h -@ $CPU ${name}.sorted.bam > ${name}.sorted.sam
samtools view -h -@ $CPU ${name}.sorted.hifi.bam > ${name}.sorted.hifi.sam
bam2fasta -u ${name}.sorted.hifi.bam -o ${name}.sorted.hifi
pbmm2 align --preset CCS $ref ${name}.sorted.hifi.bam ${name}.sorted.hifi.mapped.bam -j $CPU
samtools view -h -@ $CPU ${name}.sorted.hifi.mapped.bam > ${name}.sorted.hifi.mapped.sam
gunzip ${name}.sorted.hifi.zmw_metrics.json.gz
perl $DIR/00-Qulity_control.pl ${name}.sorted.hifi.zmw_metrics.json
perl $DIR/01-Split_fasta.pl ${name}.sorted.hifi.fasta ${name}_ccs_reference
perl $DIR/02-Split_singlemolecular.pl ${name}.sorted.hifi.sam ${name}.sorted.sam ${name}_splited_sam $Passes $FragmentSize
perl $DIR/03-Identity_source.pl ${name}.sorted.hifi.fasta $ref ${name}_blastn.xls $CPU $Identity $Coverage
perl $DIR/04-Pbmm2_ipdSummary.pl ${name}_splited_sam ${name}_ccs_reference ${name}_bam ${name}_mapped_bam ${name}_ipdsummary $CPU Full_length_ccs.txt
find $(realpath ${name}_ipdsummary/) -type f -name "*.csv" | awk -v cpu="$CPU" -v n="$name" '{print > n "_tmp_file" (NR%cpu+1) ".txt"}'
for num in $(seq 1 ${CPU});do perl $DIR/05-Extract_A_IPD.pl ${name}_tmp_file${num}.txt ${name}_all_A_IPD/${num}.txt &
done
wait
rm *_tmp_file*txt
cat ${name}_all_A_IPD/*.txt > ${name}_all_A_IPD.txt
perl $DIR/Base_quality_check.pl ${name}_all_A_IPD.txt $cut $binnumber
python $DIR/Adapter_plot.py ${name}_all_A_IPD.txt_IPDr_Statistics.txt
