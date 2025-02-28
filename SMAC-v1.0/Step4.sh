#!/bin/bash

CPU=1
name=""
SD_cutoff="0.6"
IPD_cutoff=""
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ref=""

usage() {
    echo "Usage: $0 -name <project_prefix> -ref <reference_fasta> -sd_cutoff <value> -ipd_cutoff <value> [-cpu <cpu>]"
    echo "Options:"
    echo "  -name          Prefix of output files (required)"
    echo "  -ref           Reference genome FASTA file (required)"
    echo "  -sd_cutoff     SD cutoff value (default: 0.6)"
    echo "  -ipd_cutoff    IPD ratio cutoff value (required)"
    echo "  -cpu           Number of CPU cores to use (default: 1)"
    echo "  -h, --help     Display this help message"
    exit 1
}

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -name)
            name="$2"
            shift 2
            ;;
	-ref)
            ref="$2"
            shift 2
            ;;
	-sd_cutoff)
            SD_cutoff="$2"
            shift 2
            ;;
        -ipd_cutoff)
            IPD_cutoff="$2"
            shift 2
            ;;
        -cpu)
            CPU="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

if [[ -z "$name" ]]; then
    echo "Error: Prefix of output file is Missing! Use -name to specify the name of your project."
    usage
fi

if [[ -z "$SD_cutoff" ]]; then
    echo "Error: SD cutoff value is missing! Use -sd_cutoff to specify the value."
    usage
fi

if [[ -z "$IPD_cutoff" ]]; then
    echo "Error: IPD cutoff value is missing! Use -ipd_cutoff to specify the value."
    usage
fi

if [[ -z "$ref" ]]; then
    echo "Error: Reference genome FASTA file is Missing! Use -ref to specify the reference FASTA file."
    exit 1
fi

input_SD="${name}_SD.txt"

perl $DIR/SD_filter.pl "$input_SD" "$SD_cutoff"

filtered_SD="${name}_SD.txt_below${SD_cutoff}.txt"

for num in $(seq 1 "$CPU"); do
    input_back2genome="${name}_back2genome/${num}.txt"
    perl $DIR/09A-6mA_features.pl "$input_back2genome" "$filtered_SD" "$IPD_cutoff" &
done
wait

cat "${name}_back2genome/"*.txt_6mAorA > "${name}_back2genome.txt_6mAorA"
awk 'BEGIN{m6A=0; total=0} {total++; if($5=="6mA") m6A++} END{printf("6mA level is %.2f%%\n", (m6A/total)*100)}' "${name}_back2genome.txt_6mAorA"

perl $DIR/10-Penetrance.pl "${name}_back2genome.txt_6mAorA"

chmod u+x $DIR/bedGraphToBigWig
awk '{print $1"\t"($2-1)"\t"($2-1)"\t"$6}' ${name}_back2genome.txt_6mAorA_penetrance | sort -k1,1 -k2,2n > ${name}_6mAorA.bedGraph
samtools faidx $ref
$DIR/bedGraphToBigWig ${name}_6mAorA.bedGraph ${ref}.fai ${name}_6mAorA.bw

mv "${name}_back2genome.txt_6mAorA_penetrance" "${name}_penetrance.xls"

perl $DIR/Motif.pl "${name}_back2genome.txt_6mAorA"

motif_file="${name}_back2genome.txt_6mAorA_motif"

python $DIR/Seqlogo.py "$motif_file" -o ${name}_6mA_motif.pdf

