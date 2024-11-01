open (IN1,"<","$ARGV[0]");#100007937       1       0       AC      0.613   NNNNNACGCGC
open (IN2,"<","$ARGV[0]");
$cut="$ARGV[1]";#cut number
open (OUT1,">","$ARGV[0]_${cut}bp_Trimmed");
while (defined ($_=<IN1>)){
	if ($_=~/^(\d+)\s+(\d+)\s+.\s+.+?\s+(.+?)\s+/){
		if (!exists $max{$1} || $2>$max{$1}){$max{$1}=$2}}}
print OUT1 "ZWM\tPosition\tstrand\tDinucleotide\tIPDr\tMotif\n";
while (defined ($_=<IN2>)){
	if ($_=~/^(\d+)\s+(\d+)\s+.\s+.+?\s+(.+?)\s+/){
		$after=$max{$1}-$cut;
		if ($2>$cut && $2<$after){
			print OUT1 "$_"}}}
