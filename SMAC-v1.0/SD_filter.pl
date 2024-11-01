open (IN1,"<","$ARGV[0]");
$SD="$ARGV[1]";
open (OUT1,">","$ARGV[0]_below$SD.txt");
while (defined ($_=<IN1>)){
	if ($_=~/^(\d+)\s+(.+?)\s+(.+)/){
		if ($2<=$SD && $3<=$SD){
			print OUT1 "$1\n"}}}
