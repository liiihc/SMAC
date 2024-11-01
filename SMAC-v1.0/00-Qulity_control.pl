open IN1,"<","$ARGV[0]";
#json.gz
#"_time_ms_draft": 750,
#"_time_ms_polish": 3062,
#"_time_ms_qvs": 552,
#"effective_coverage": 60.0,
#"has_tandem_repeat": false,
#"insert_size": 1763,
#"num_full_passes": 60,
#"polymerase_length": 124422,
#"predicted_accuracy": 1.0,
#"status": "SUCCESS",
#"wall_end": 7408858,
#"wall_start": 2354829,
#"zmw": "m64335e_221030_023144/0"
open (OUT1,">","$ARGV[0]_QC");
my (@file,$a,$b,$c,$d,$e,$f,$g,$h,$i,$j,$k,$l,$m,$n,$sum,$number);
$a=0;$b=0;$c=0;$d=0;$e=0;$f=0;$g=0;$h=0;$i=0;$j=0;$k=0;$l=0;$m=0;$n=0;
@file=<IN1>;

foreach $_(@file){
	if ($_=~/"insert_size":\s+(\d+)/){
		$zmw++;
		push @arr,$1;
		$insert+=$1;
		if ($1<=500){$a+=1}
		elsif ($1<=1000){$b+=1}
		elsif ($1<=2000){$c+=1}
		elsif ($1<=2500){$d+=1}
		elsif ($1<=3000){$e+=1}
		elsif ($1<=3500){$f+=1}
                elsif ($1<=4000){$g+=1}
                elsif ($1<=4500){$h+=1}
                elsif ($1<=5000){$i+=1}
		elsif ($1<=6000){$j+=1}
                elsif ($1<=10000){$k+=1}
                elsif ($1<=15000){$l+=1}
                elsif ($1<=20000){$m+=1}
		else {$n+=1}}}
@arr_sort=sort @arr;
$insert=$insert/$zmw;
$insert = sprintf("%.2f", $insert);
$mid=int($zmw/2)-1;

print OUT1 "Insert Size Statistics:\n";
print OUT1 "----------------------------\n";
print OUT1 "Median length: $arr_sort[$mid]\n";
print OUT1 "Average insert length: $insert\n";
print OUT1 "\n";
print OUT1 "Insert Size Distribution:\n";
print OUT1 "----------------------------\n";
print OUT1 "0-500\t\t$a\n";
print OUT1 "500-1000\t$b\n";
print OUT1 "1000-2000\t$c\n";
print OUT1 "2000-2500\t$d\n";
print OUT1 "2500-3000\t$e\n";
print OUT1 "3000-3500\t$f\n";
print OUT1 "3500-4000\t$g\n";
print OUT1 "4000-4500\t$h\n";
print OUT1 "4500-5000\t$i\n";
print OUT1 "5000-6000\t$j\n";
print OUT1 "6000-10000\t$k\n";
print OUT1 "10000-15000\t$l\n";
print OUT1 "15000-20000\t$m\n";
print OUT1 ">20000\t\t$n\n";
print OUT1 "\n";
print OUT1 "Total molecules: $zmw\n";

$a=0;$b=0;$c=0;$d=0;$e=0;$f=0;$g=0;$h=0;$i=0;$j=0;$k=0;$l=0;$m=0;$n=0;
foreach $_(@file){
        if ($_=~/"polymerase_length":\s+(\d+)/){
                $sum+=$1;
		$number++;
		push (@length,$1);
		if ($1<=2500){$a+=1}
                elsif ($1<=5000){$b+=1}
                elsif ($1<=10000){$c+=1}
                elsif ($1<=20000){$d+=1}
                elsif ($1<=50000){$e+=1}
                elsif ($1<=100000){$f+=1}
                elsif ($1<=200000){$g+=1}
                elsif ($1<=300000){$h+=1}
		elsif ($1<=400000){$i+=1}
                elsif ($1<=500000){$j+=1}
                elsif ($1<=600000){$k+=1}
                else {$l+=1}}}

$ave=$sum/$number;
$ave = sprintf("%.2f", $ave);
$n50=$sum/2;
open (OUT2,">","tmp.txt");
foreach $_(@length){print OUT2 "$_\n"};
close (OUT2);
system "sort -n tmp.txt > tmp_sort.txt";
open (IN2,"<","tmp_sort.txt");
@length_sort=<IN2>;
$tmp=0;
$max=$length_sort[-1];
while ($N50<$n50){
	$N50+=$length_sort[$tmp];
	$tmp+=1;}
system "rm tmp.txt tmp_sort.txt";

print OUT1 "\nPolymerase Length Statistics:\n";
print OUT1 "------------------------------\n";
print OUT1 "Number of Bases: $sum\n";
print OUT1 "Number of Reads: $number\n";
print OUT1 "Average Length: $ave\n";
print OUT1 "N50: $length_sort[$tmp]\n";
print OUT1 "Max Polymerase Length: $max\n";
print OUT1 "\n";
print OUT1 "Polymerase Length Distribution:\n";
print OUT1 "------------------------------\n";
print OUT1 "0-2500\t\t$a\n";
print OUT1 "2500-5000\t$b\n";
print OUT1 "5000-10000\t$c\n";
print OUT1 "10000-20000\t$d\n";
print OUT1 "20000-50000\t$e\n";
print OUT1 "50000-100000\t$f\n";
print OUT1 "100000-200000\t$g\n";
print OUT1 "200000-300000\t$h\n";
print OUT1 "300000-400000\t$i\n";
print OUT1 "400000-500000\t$j\n";
print OUT1 "500000-600000\t$k\n";
print OUT1 ">600000\t\t$l\n";

