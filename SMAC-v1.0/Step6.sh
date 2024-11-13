name=""
all_cutoff=""
W_cutoff=""
C_cutoff=""
ref=""
CPU=1
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
    echo "Usage: $0 -name <project_prefix> -all_cutoff <value> -W_cutoff <value> -C_cutoff <value> -ref <genome.fasta>"
    echo "Options:"
    echo "  -name          Prefix of output files (required)"
    echo "  -all_cutoff    All A IPD ratio cutoff value (required)"
    echo "  -W_cutoff      W strand IPD ratio cutoff value (required)"
    echo "  -C_cutoff      C strand IPD ratio cutoff value (required)"
    echo "  -ref           Reference genome FASTA file (required)"    
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
        -all_cutoff)
            all_cutoff="$2"
            shift 2
            ;;
        -W_cutoff)
            W_cutoff="$2"
            shift 2
            ;;
        -C_cutoff)
            C_cutoff="$2"
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

if [[ -z "$all_cutoff" ]]; then
    echo "Error: All cutoff value is missing! Use -all_cutoff to specify the value."
    usage
fi

if [[ -z "$W_cutoff" ]]; then
    echo "Error: W cutoff value is missing! Use -W_cutoff to specify the value."
    usage
fi

if [[ -z "$C_cutoff" ]]; then
    echo "Error: C cutoff value is missing! Use -C_cutoff to specify the value."
    usage
fi

if [[ -z "$ref" ]]; then
    echo "Error: Reference genome FASTA file is Missing! Use -ref to specify the reference FASTA file."
    exit 1
fi

output_dir="${name}_shifted_cutoff"

mkdir -p "$output_dir"
for num in $(seq 1 "$CPU"); do
    input_file="${name}_back2genome/${num}.txt"
    perl $DIR/09B-6mApT_features.pl "$input_file" "$output_dir" "$all_cutoff" "$W_cutoff" "$C_cutoff" "$num" &
done
wait
perl $DIR/6mAratio.pl $output_dir ${name}_6mAratio.xls

cat ${name}_shifted_cutoff/*6mAorA_inApT_doubleCutoff > ${name}_6mApTorApT
perl $DIR/10-Penetrance.pl ${name}_6mApTorApT
chmod u+x $DIR/bedGraphToBigWig
awk '{print $1"\t"($2-1)"\t"($2-1)"\t"$6}' ${name}_6mApTorApT_penetrance | sort -k1,1 -k2,2n > ${name}_6mApTorApT.bedGraph
samtools faidx $ref
$DIR/bedGraphToBigWig ${name}_6mApTorApT.bedGraph ${ref}.fai ${name}_6mApTorApT.bw
