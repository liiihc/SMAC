open (IN1,"<","$ARGV[0]");#hifi pbmm2.sam
#m64268e_240425_131657/205/ccs   0       chr_073 135952  60      17S1915=1D177=1D40=1D94=13S     *       0       2229    ATATATCTTTTAACTCTAATATATAAAGCAATACGCAGTTTTTAATTTATTATTTTGTAAACATAAAAAATCCAAATATGGATATAATTTTAAAACAGAATTGGAATAATTTAAATGGAATTTAGATATTTTTTCATTTTTTTCTTCTTATTTGAATATCTATAGACATAT        *       RG:Z:default    qs:i:0  qe:i:2256       mg:f:99.8654
open (IN2,"<","$ARGV[1]");#chimic 1000    chr_029 2626    W       no6mA   AT      TAAAAATATAA
$fa="$ARGV[2]";
open (OUT1,">","$ARGV[3]");
#system "rm tmp.file";
while (defined ($sam=<IN1>)){
	if ($sam!~/SA:Z/){
	if ($sam=~/m.+?\/(\d+)\/ccs\s+.+?\s+(.+?)\s+(\d+)\s+.+?\s+(.+?)\s+/){
		$zmw=$1;
		$chr{$zmw}=$2;
		$pos=$3;
		$F=$4;
		$start=$pos;
		while ($F=~/^(\d+[\=|I|X|S|D])(.*)/){
                        $tmp=$1;$F=$2;
			if ($tmp=~/(\d+)[\=|X|D]/){
                                $pos+=$1}}
		$pos=$pos-1;
		$start{$zmw}=$start;
		$length{$zmw}=$pos-$start+1;
		$sam{$zmw}=1;}
#		system "echo '>$zmw' >> tmp.file; samtools faidx $fa $chr{$zmw}:$start-$pos |grep -v '>' >> tmp.file"}
	elsif($sam=~/^@/) {$header.=$sam}}}
print OUT1 "$header";
open (IN3,"<","tmp.file");
while (defined ($_=<IN3>)){
        if(/>(.+?)\n/){$name=$1;
                }else{chomp $_;$Fa{$name}.=$_}
                }
system "rm tmp.file";
$zmw=0;
while (defined ($_=<IN2>)){
	if ($_=~/^(\d+)\s+(.+?)\s+(\d+)\s+(.)\s+(.+?)\s+/){
		$zmw=$1;
		$pos=$3;
		$num=$pos-$start{$zmw};
		$zmw{$1}=1;
		if ($5 eq "6mA"){if ($4 eq "C"){$hemi_C{$1}=$hemi_C{$1}.",".$num}else {$hemi_W{$1}=$hemi_W{$1}.",".$num}}}}
foreach $zmw(sort {$a cmp $b} keys %zmw){
	if (exists $sam{$zmw}){
	@seq=split ("",$Fa{$zmw});
	@W=split (",",$hemi_W{$zmw});
	@C=split (",",$hemi_C{$zmw});
	$x=0;$seq="";$cigar="";$tmp=0;$tmp1=0;$o=0;
	foreach $a(@seq){
		if (grep {$_ eq $x} @W){
			$seq.="G";$tmp1++;if ($tmp>0) {$cigar.="${tmp}=";$o+=$tmp};$tmp=0;
			$x++}
		elsif (grep {$_ eq $x} @C){
                        $seq.="C";$tmp1++;if ($tmp>0) {$cigar.="${tmp}=";$o+=$tmp};$tmp=0;
                        $x++}
		else {$seq.=$a;
			if ($tmp1>0){$cigar.="${tmp1}X";$o+=$tmp1};$tmp1=0;
			$tmp++;
			$x++;}}
	if ($tmp1>0){$cigar.="${tmp1}X";$o+=$tmp1};
	if ($tmp>0) {$cigar.="${tmp}=";$o+=$tmp};
	print OUT1 "$zmw\t0\t$chr{$zmw}\t$start{$zmw}\t60\t$cigar\t\*\t0\t$length{$zmw}\t$seq\t\*\tRG:Z:default\n"}}
