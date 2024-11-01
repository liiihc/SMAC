$path="$ARGV[0]";
@file=glob ("$path/*6mAratio");
foreach $file(@file){
	open (IN1,"<","$file");
	while (defined ($_=<IN1>)){
		if ($_=~/^(.+?):(\d+)/){
			$hash{$1}+=$2}}}
$m6ApT_ApT=$hash{"6mApT"}/$hash{AT};
$m6A_A=($hash{"6mApT"}+$hash{"6mApN"})/$hash{A};
$m6ApTratio=$hash{"6mApT"}/($hash{"6mApT"}+$hash{"6mApN"});
$full=$hash{Full}/$hash{"6mApT"};
$hemi_W=$hash{"Hemi-W"}/$hash{"6mApT"};
$hemi_C=$hash{"Hemi-C"}/$hash{"6mApT"};
$m6A=$hash{"6mApT"}+$hash{"6mApN"};
open (OUT1,">","$ARGV[1]");
print OUT1 "total A:$hash{A}\ntotal 6mA:$m6A\n6mA/A:$m6A_A\ntotal ApT:$hash{AT}\ntotal 6mApT:$hash{\"6mApT\"}\n6mApT/ApT:$m6ApT_ApT\n6mApT/6mA:$m6ApTratio\nFull 6mApT:$full\nHemi-W 6mApT:$hemi_W\nHemi-C 6mApT:$hemi_C"
