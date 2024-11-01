open (IN1,"<","$ARGV[0]");#1000    chr_029 2449    C       1.281   AN      AAAAAANNNNN
open (IN2,"<","$ARGV[0]");
$IPD="$ARGV[1]";
open (OUT1,">","$ARGV[0]_Wstrand_IPDr_distribution");
open (OUT2,">","$ARGV[0]_Cstrand_IPDr_distribution");
sub log2 {
my $n = shift;
return log($n)/log(2);
}
while (defined ($_=<IN1>)){
	if ($_=~/^(\d+\s+.+?\s+\d+)\s+W\s+(.+?)\s+/){
		$W{$1}=$2}
	if ($_=~/^(\d+\s+.+?\s+\d+)\s+C\s+(.+?)\s+/){
                $C{$1}=$2}}
while (defined ($_=<IN2>)){
	if ($_=~/^(\d+\s+.+?)\s+(\d+)\s+(.)\s+(.+?)\s+/ && $4>=$IPD){
		$chr=$1;
		$pos=$2;
		$strand=$3;
		if ($strand eq "W"){
			$pos=$2+1;
			$tmp="$chr\t$pos";
			$C=$C{$tmp};
			if ($C>0){
                        my $ipd=&log2($C);
                        foreach my $x (0..99){
                                        my $a=0.05*$x;
                                        my $b=0.05*($x+1);
                                        my $c=-$a;
                                        my $d=-$b;
                                        if($ipd>$a and $ipd<=$b){$C_IPD{$a}++;
                                       }elsif($ipd>$d and $ipd<=$c){$C_IPD{$d}++}}}}
		if ($strand eq "C"){
                        $pos=$2-1;
                        $tmp="$chr\t$pos";
                        $W=$W{$tmp};
                        if ($W>0){
                        my $ipd=&log2($W);
                        foreach my $x (0..99){
                                        my $a=0.05*$x;
                                        my $b=0.05*($x+1);
                                        my $c=-$a;
                                        my $d=-$b;
                                        if($ipd>$a and $ipd<=$b){$W_IPD{$a}++;
                                       }elsif($ipd>$d and $ipd<=$c){$W_IPD{$d}++}}}}}}
@keys= sort {$a <=> $b}  keys(%W_IPD);
foreach my $keys(@keys){
                my $left=$keys;
                my $right=$keys+0.05;
                if (!(exists $W_IPD{$keys})){$W_IPD{$keys}=0}
                if (!(exists $C_IPD{$keys})){$C_IPD{$keys}=0}
                print OUT1 "($left,$right]\t$W_IPD{$keys}\n";
		print OUT2 "($left,$right]\t$C_IPD{$keys}\n";}
			
