use strict;
my (@files,$sequence,%basef,%baser,$n,$a,$b,$pos1,$pos2,$pos3,$pos4,$pos5,$pos6,$pos7,$pos8,$pos9,$pos10,);
open (IN,"<","$ARGV[0]");
@files=<IN>;
open (OUT1,">","$ARGV[1]");
foreach $_(@files){
        if ($_=~/\/(\d+).csv/){
		chomp $_;
		open (IN1,"<","$_");
		open (IN2,"<","$_");
		while (defined ($sequence=<IN1>)){
			if ($sequence=~/"m.+?\/(\d+)\/ccs",(\d+),0,(.),.+?,.+?,.+?,.+?,(.+?),/){
				$basef{$2}=$3;
			}
			if ($sequence=~/"m.+?\/(\d+)\/ccs",(\d+),1,(.),.+?,.+?,.+?,.+?,(.+?),/){
				$baser{$2}=$3;
			}
		}
		while (defined ($sequence=<IN2>)){
			if ($sequence=~/"m.+?\/(\d+)\/ccs",(\d+),0,A,.+?,.+?,.+?,.+?,(.+?),/){
				foreach $n (1..5){
					$a=$2+$n;
					$b=$2-$n;
					if(!(exists $basef{$a})){
						$basef{$a}="N";
					}
					if(!(exists $basef{$b})){
						$basef{$b}="N";
					}
				}
				$pos1=$2-5;
				$pos2=$2-4;
				$pos3=$2-3;
				$pos4=$2-2;
				$pos5=$2-1;
				$pos6=$2+1;
				$pos7=$2+2;
				$pos8=$2+3;
				$pos9=$2+4;
				$pos10=$2+5;
				print OUT1 "$1\t$2\t0\tA$basef{$pos6}\t$3\t$basef{$pos1}$basef{$pos2}$basef{$pos3}$basef{$pos4}$basef{$pos5}A$basef{$pos6}$basef{$pos7}$basef{$pos8}$basef{$pos9}$basef{$pos10}\n";
			}
			if ($sequence=~/"m.+?\/(\d+)\/ccs",(\d+),1,A,.+?,.+?,.+?,.+?,(.+?),/){
				foreach $n (1..5){
					$a=$2+$n;
					$b=$2-$n;
					if(!(exists $baser{$a})){
						$baser{$a}="N";
					}
					if(!(exists $baser{$b})){
						$baser{$b}="N";
					}
				}
				$pos1=$2+5;
				$pos2=$2+4;
				$pos3=$2+3;
				$pos4=$2+2;
				$pos5=$2+1;
				$pos6=$2-1;
				$pos7=$2-2;
				$pos8=$2-3;
				$pos9=$2-4;
				$pos10=$2-5;
				print OUT1 "$1\t$2\t1\tA$baser{$pos6}\t$3\t$baser{$pos1}$baser{$pos2}$baser{$pos3}$baser{$pos4}$baser{$pos5}A$baser{$pos6}$baser{$pos7}$baser{$pos8}$baser{$pos9}$baser{$pos10}\n";
			}
		}
	}
}
