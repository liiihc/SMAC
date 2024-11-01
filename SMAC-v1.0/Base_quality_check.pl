use Statistics::Descriptive;
open (IN1,"<","$ARGV[0]");#100007937       1       0       AC      0.613   NNNNNACGCGC
open (IN2,"<","$ARGV[0]");
$cut="$ARGV[1]";#cut number
$bn="$ARGV[2]";#bin number
open (OUT1,">","$ARGV[0]_IPDr_Statistics.txt");
while (defined ($_=<IN1>)){
	if ($_=~/^(\d+)\s+(\d+)\s+.\s+.+?\s+(.+?)\s+/){
		if (!exists $max{$1} || $2>$max{$1}){$max{$1}=$2}}}
while (defined ($_=<IN2>)){
	if ($_=~/^(\d+)\s+(\d+)\s+.\s+.+?\s+(.+?)\s+/){
		$after=$max{$1}-$cut;
		$bs=($after-$cut)/$bn;
		if ($2<=$cut){
			$tmp="B$2";
			$num{$tmp}++;
			if ($3<0.01){$zero{$tmp}++}
			if (!exists $hash{$tmp}){$hash{$tmp}=Statistics::Descriptive::Full->new();$hash{$tmp}->add_data($3)}
			else {$hash{$tmp}->add_data($3)}}
		elsif ($2>$after){
			$tmp=$2-$after;
			$tmp="A$tmp";
			$num{$tmp}++;
                        if ($3<0.01){$zero{$tmp}++}
			if (!exists $hash{$tmp}){$hash{$tmp}=Statistics::Descriptive::Full->new();$hash{$tmp}->add_data($3)}
                        else {$hash{$tmp}->add_data($3)}}
		else {$bin=1+int(($2-$cut)/$bs);
			if ($bin>$bn){$bin=$bin-1}
			$tmp="bin$bin";
			$num{$tmp}++;
                        if ($3<0.01){$zero{$tmp}++}
			if (!exists $hash{$tmp}){$hash{$tmp}=Statistics::Descriptive::Full->new();$hash{$tmp}->add_data($3)}
                        else {$hash{$tmp}->add_data($3)}}}}
print OUT1 "Position\tMin\tMedian\tMax\tQ1\tQ3\tZero IPDr\n";
foreach (1..$cut){
	$B="B$_";
	$A="A$_";
	$A_min=$hash{$A}->min();
	$A_median=$hash{$A}->median();
	$A_max=$hash{$A}->max();
	$A_q1=$hash{$A}->quantile(1);
	$A_q3=$hash{$A}->quantile(3);
	$A_zero=100*$zero{$A}/$num{$A};
	$B_min=$hash{$B}->min();
        $B_median=$hash{$B}->median();
        $B_max=$hash{$B}->max();
	$B_q1=$hash{$B}->quantile(1);
        $B_q3=$hash{$B}->quantile(3);
	$B_zero=1000*$zero{$B}/$num{$B};
	print OUT1 "$A\t$A_min\t$A_median\t$A_max\t$A_q1\t$A_q3\t$A_zero\n";
	print OUT1 "$B\t$B_min\t$B_median\t$B_max\t$B_q1\t$B_q3\t$B_zero\n";}
foreach (1..$bn){
	$tmp="bin$_";
	$min=$hash{$tmp}->min();
        $median=$hash{$tmp}->median();
        $max=$hash{$tmp}->max();
	$q1=$hash{$tmp}->quantile(1);
        $q3=$hash{$tmp}->quantile(3);
	$zero=1000*$zero{$tmp}/$num{$tmp};
        print OUT1 "$tmp\t$min\t$median\t$max\t$q1\t$q3\t$zero\n"}
