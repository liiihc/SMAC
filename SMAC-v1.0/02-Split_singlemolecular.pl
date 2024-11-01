open (IN1, "<", "$ARGV[0]");#hifi.sam
open (IN2, "<", "$ARGV[1]");#subreads.sam
$out_path=$ARGV[2];
$Pass=$ARGV[3];
$FragmentSize=$ARGV[4];
open (OUT1, ">", "$ARGV[0]_ZMW_${Pass}x.$FragmentSize.txt");
while(defined($line=<IN1>)){
	if($line=~/^m.+?_.+?_.+?\/(\d+?)\/ccs\t.+?\t.+?\t.+?\t.+?\t.+?\t.+?\t.+?\t.+?\t(.+?)\t.+?\t.+?\tec:f:(.+?)\t.+?\n/){
		$pass=int($3+1);
		if($pass>=$Pass){
			$zmw{$1}=1;
			print OUT1 "$1\n";
		}
	}
}
system "mkdir $out_path";
$n=0;
while(defined($line=<IN2>)){
	if($line=~/^@.*?\n/){
		$header=join("",$header,$line);
	}
	if($line=~/^m.+?_.+?_.+?\/(.+?)\/(.+?)_(.+?)\t.+?\n/){
		$length=$3-$2+1;
		if(exists $zmw{$1} && $length>=$FragmentSize){
			if($zmw eq $1){
				$n++;
				$sam[$n]=$line;
			}else{
				if($n>0){
					open (OUT, ">", "$out_path/$zmw.sam");
					print OUT "$header";
					foreach  $_(@sam){
						print OUT "$_";
					}
				}
				$zmw=$1;
				$n=0;
				undef @sam;
				$sam[$n]=$line;
			}
		}
	}
}
open (OUT, ">", "$out_path/$zmw.sam");
print OUT "$header";
foreach $_(@sam){
	print OUT "$_";
}
$n=0;
undef @sam;

