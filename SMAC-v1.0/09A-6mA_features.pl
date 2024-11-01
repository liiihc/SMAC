open (IN1,"<","$ARGV[0]");#all A IPD file
open (IN2,"<","$ARGV[1]");
open (OUT1,">","$ARGV[0]_6mAratio");#ratio file
open (OUT2,">","$ARGV[0]_6mAorA");#output file
$num_A=0;
$m6A=0;
$CUTOFF=2**$ARGV[2];
while (defined ($_=<IN2>)){
	if ($_=~/(\d+)/){
		$hash{$1}=1}}
while (defined ($A=<IN1>)){
	if ($A=~/(\d+)\s+(.+?)\s+(\d+)\s+(.)\s+(.+)\s+(A.)\s+(.+)/ && exists $hash{$1}){
		$num_A++;
		if ($5>=$CUTOFF){print OUT2 "$1\t$2\t$3\t$4\t6mA\t$6\t$7\n";$m6A++}
		else {print OUT2 "$1\t$2\t$3\t$4\tno6mA\t$6\t$7\n"}}}
$m6A_A=$m6A/$num_A;
print OUT1 "A sites:$num_A\n6mA sites:$m6A\n6mA/A:$m6A_A";
