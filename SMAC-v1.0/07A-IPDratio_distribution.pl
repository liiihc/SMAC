#zmw     chromosome 42685   W       0.868   AT      AACAAATAATT
open (IN1,"<","$ARGV[0]");
$path=$ARGV[1];
$name=$ARGV[0];
if ($name=~/back2genome\/(\d+).txt/){
	$cpu=$1}
system "mkdir $path;
	mkdir $path/A;
	mkdir $path/ApT;
	mkdir $path/ApG;
	mkdir $path/ApC;
	mkdir $path/ApA";
open (OUT1,">","$path/A/${cpu}.txt");
open (OUT2,">","$path/ApT/${cpu}.txt");
open (OUT3,">","$path/ApG/${cpu}.txt");
open (OUT4,">","$path/ApC/${cpu}.txt");
open (OUT5,">","$path/ApA/${cpu}.txt");
sub log2 {
my $n = shift;
return log($n)/log(2);
}
while (defined ($A=<IN1>)){
        if ($A=~/^(\d+)\s+.+?\s+\d+\s+.\s+(.+?)\s+AT\s+/){
			if ($2>0){
                        my $ipd=&log2($2);
                        foreach my $x (0..99){
                                        my $a=0.05*$x;
                                        my $b=0.05*($x+1);
                                        my $c=-$a;
                                        my $d=-$b;
                                        if($ipd>$a and $ipd<=$b){$A{$a}++;
                                                                 $AT{$a}++;
                                       }elsif($ipd>$d and $ipd<=$c){$A{$d}++;
                                                                 $AT{$d}++;
                                                                                }
                                       }}}
	elsif ($A=~/^(\d+)\s+.+?\s+\d+\s+.\s+(.+?)\s+AG\s+/){
                        if ($2>0){
                        my $ipd=&log2($2);
                        foreach my $x (0..99){
                                        my $a=0.05*$x;
                                        my $b=0.05*($x+1);
                                        my $c=-$a;
                                        my $d=-$b;
                                        if($ipd>$a and $ipd<=$b){$A{$a}++;
                                                                 $AG{$a}++;
                                       }elsif($ipd>$d and $ipd<=$c){$A{$d}++;
                                                                 $AG{$d}++;
                                                                                }
                                       }}}
	elsif ($A=~/^(\d+)\s+.+?\s+\d+\s+.\s+(.+?)\s+AC\s+/){
                        if ($2>0){
                        my $ipd=&log2($2);
                        foreach my $x (0..99){
                                        my $a=0.05*$x;
                                        my $b=0.05*($x+1);
                                        my $c=-$a;
                                        my $d=-$b;
                                        if($ipd>$a and $ipd<=$b){$A{$a}++;
                                                                 $AC{$a}++;
                                       }elsif($ipd>$d and $ipd<=$c){$A{$d}++;
                                                                 $AC{$d}++;
                                                                                }
                                       }}}
	elsif ($A=~/^(\d+)\s+.+?\s+\d+\s+.\s+(.+?)\s+AA\s+/){
                        if ($2>0){
                        my $ipd=&log2($2);
                        foreach my $x (0..99){
                                        my $a=0.05*$x;
                                        my $b=0.05*($x+1);
                                        my $c=-$a;
                                        my $d=-$b;
                                        if($ipd>$a and $ipd<=$b){$A{$a}++;
                                                                 $AA{$a}++;
                                       }elsif($ipd>$d and $ipd<=$c){$A{$d}++;
                                                                 $AA{$d}++;
                                                                                }
                                       }}}
	}
@keys= sort {$a <=> $b}  keys(%A);
foreach my $keys(@keys){
                my $left=$keys;
                my $right=$keys+0.05;
		if (!(exists $AT{$keys})){$AT{$keys}=0}
		if (!(exists $AG{$keys})){$AG{$keys}=0}
		if (!(exists $AC{$keys})){$AC{$keys}=0}
		if (!(exists $AA{$keys})){$AA{$keys}=0}
                print OUT1 "($left,$right]\t$A{$keys}\n";
		print OUT2 "($left,$right]\t$AT{$keys}\n";
		print OUT3 "($left,$right]\t$AG{$keys}\n";
		print OUT4 "($left,$right]\t$AC{$keys}\n";
		print OUT5 "($left,$right]\t$AA{$keys}\n";
}
