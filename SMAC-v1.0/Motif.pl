open (IN1,"<","$ARGV[0]");#100007937       1       0       AC      6mA   NNNNNACGCGC
open (OUT1,">","$ARGV[0]_motif");
while (defined ($_ = <IN1>)) {
    if ($_ =~ /.+?\s+.+?\s+.+?\s+.+?\s+(.+?)\s+.+?\s+(\w+)$/ && $1 eq "6mA") {
        @motif = split("", $2);
        foreach my $a (0..10) {
            $b = $motif[$a];
            $count{$b}[$a]++} 
    }
    }
foreach $a(0..10){
	$count=$count{A}[$a]+$count{T}[$a]+$count{C}[$a]+$count{G}[$a];
	$A[$a]=$count{A}[$a]/$count;
	$T[$a]=$count{T}[$a]/$count;
	$C[$a]=$count{C}[$a]/$count;
        $G[$a]=$count{G}[$a]/$count;
	}
print OUT1 "Position\t-5\t-4\t-3\t-2\t-1\t0\t1\t2\t3\t4\t5\n";
print OUT1 "A\t$A[0]\t$A[1]\t$A[2]\t$A[3]\t$A[4]\t$A[5]\t$A[6]\t$A[7]\t$A[8]\t$A[9]\t$A[10]\n";
print OUT1 "T\t$T[0]\t$T[1]\t$T[2]\t$T[3]\t$T[4]\t$T[5]\t$T[6]\t$T[7]\t$T[8]\t$T[9]\t$T[10]\n";
print OUT1 "C\t$C[0]\t$C[1]\t$C[2]\t$C[3]\t$C[4]\t$C[5]\t$C[6]\t$C[7]\t$C[8]\t$C[9]\t$C[10]\n";
print OUT1 "G\t$G[0]\t$G[1]\t$G[2]\t$G[3]\t$G[4]\t$G[5]\t$G[6]\t$G[7]\t$G[8]\t$G[9]\t$G[10]\n";
