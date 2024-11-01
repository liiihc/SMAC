CPU=1
name=""
IPD_cutoff=""
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
    echo "Usage: $0 -name <project_prefix> -ipd_cutoff <value> [-cpu <cpu>]"
    echo "Options:"
    echo "  -name          Prefix of output files (required)"
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

if [[ -z "$IPD_cutoff" ]]; then
    echo "Error: IPD cutoff value is missing! Use -ipd_cutoff to specify the value."
    usage
fi

for num in $(seq 1 "$CPU"); do
    input_file="${name}_back2genome/${num}.txt"
    perl $DIR/07B-IPDratio_distribution_forApT.pl "$input_file" "$IPD_cutoff" &
done
wait

mkdir -p ${name}_ApT_IPDr_distribution
mv ${name}_back2genome/*strand_IPDr_distribution ${name}_ApT_IPDr_distribution/

perl $DIR/cat-ApT.pl ${name}_ApT_IPDr_distribution/
#cat ${name}_ApT_IPDr_distribution/*_Wstrand_IPDr_distribution > ${name}_ApT_IPDr_distribution/W_IPDr_distribution.txt
#cat ${name}_ApT_IPDr_distribution/*_Cstrand_IPDr_distribution > ${name}_ApT_IPDr_distribution/C_IPDr_distribution.txt


python $DIR/6mA_axdistribution_leftpeak.py ${name}_ApT_IPDr_distribution/W_IPDr_distribution.txt
python $DIR/6mA_axdistribution_leftpeak.py ${name}_ApT_IPDr_distribution/C_IPDr_distribution.txt

