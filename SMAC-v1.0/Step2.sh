CPU=1
trimmer=25
name=""
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
usage() {
    echo "Usage: $0 -name <project_prefix> [-cpu <cpu>] [-trimmer <trimmer>]"
    echo "Options:"
    echo "  -name        Prefix of output files (required)"
    echo "  -cpu         Number of CPU cores to use (default: 1)"
    echo "  -trimmer     Number of bases to trim from 5' and 3' ends (default: 25)"
    echo "  -h, --help   Display this help message"
    exit 1
}

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -name)
            name="$2"
            shift 2
            ;;
        -cpu)
            CPU="$2"
            shift 2
            ;;
        -trimmer)
            trimmer="$2"
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
    exit 1
fi


mkdir -p "${name}_all_A_IPD"
mkdir -p "${name}_back2genome"
mkdir -p "${name}_A_IPDr_distribution"

for num in $(seq 1 "$CPU"); do
    perl $DIR/Trim_adapter.pl "${name}_all_A_IPD/${num}.txt" "$trimmer" &
done
wait

for num in $(seq 1 "$CPU"); do
    perl $DIR/06-Back_to_genome.pl "${name}.sorted.hifi.mapped.sam" "${name}_all_A_IPD/${num}.txt_${trimmer}bp_Trimmed" "${name}_back2genome/${num}.txt" &
done
wait

for num in $(seq 1 "$CPU"); do
    perl $DIR/07A-IPDratio_distribution.pl "${name}_back2genome/${num}.txt" "${name}_A_IPDr_distribution" &
done
wait

perl $DIR/cat-A.pl ${name}_A_IPDr_distribution/A
#You should install "lmfit,scipy,statsmodels,pandas,matplotlib,numpy" python packages.
python $DIR/6mA_axdistribution_rightpeak.py ${name}_A_IPDr_distribution/A/A_IPDr_distribution.txt
