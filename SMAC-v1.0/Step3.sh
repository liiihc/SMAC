CPU=1
IPD_cutoff=""
name=""
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
    exit 1
fi

if [[ -z "$IPD_cutoff" ]]; then
    echo "Error: IPD cutoff value is missing! Use -ipd_cutoff to specify the value."
    usage
fi

input_sam="${name}.sorted.hifi.mapped.sam"
input_ipdsummary="${name}_ipdsummary"

mkdir -p "${name}_SD"

for num in $(seq 1 "$CPU"); do
    perl $DIR/08-Calculate_SD.pl "$input_ipdsummary" "$input_sam" "${name}_SD/${num}.txt" "$IPD_cutoff" &
done
wait

cat "${name}_SD/"*.txt > "${name}_SD.txt"

python $DIR/SD_plot.py "${name}_SD.txt"
