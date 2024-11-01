$path=$ARGV[0];
system "rm $path/A_IPDr_distribution.txt;cat $path/*txt > tmp.txt";
open (IN1,"<","tmp.txt");
open (OUT1,">","$path/A_IPDr_distribution.txt");
while (defined ($_=<IN1>)){
        if ($_=~/\((.+?),.+?\s+(\d+)/){
                $hash{$1}+=$2;}}
foreach $x (reverse(0..99)){
                   $a=-0.05*$x;
                   $b=-0.05*($x+1);
                   if (! exists $hash{$a}){$hash{$a}=1}
                   print OUT1 "($a,$b]\t$hash{$a}\n";}
foreach $x (0..99){
                   $a=0.05*$x;
                   $b=0.05*($x+1);
                   if (! exists $hash{$a}){$hash{$a}=1}
                   print OUT1 "($a,$b]\t$hash{$a}\n";}
system "rm tmp.txt"
