my (%hash,$pos,@files,%strand,%csv,$sequence,$strand,%strand,$zmw,%N,$IPD,$num,@csv,$zwm,$pos2,$tmp,$SD_sum_ws,$SD_sum_cr,$ave_ws,$ave_cr,$num_ws,$num_cr,$SD_ws,$SD_cr);
@files=glob "$ARGV[0]/*csv";#ipdsummary result directory pathway
open (IN1,"<","$ARGV[1]");#hifi.pbmm2.sam
open (OUT1,">","$ARGV[2]");#SD output file
$cutoff=2**$ARGV[3];#IPD ratio cutoff
while (defined ($zwm=<IN1>)){
	if ($zwm=~/\/(\d+)\/ccs\s+0\s+/ && $zwm!~/SA:Z/){
			$strand{$1}=0}
	if ($zwm=~/\/(\d+)\/ccs\s+16\s+/ && $zwm!~/SA:Z/){
                        $strand{$1}=1}}
my ($IPD_ws,$IPD_cr,$num_ws,$num_cr,@IPD_cr,@IPD_ws);
foreach $_(@files){
        if ($_=~/\/(\d+).csv/){$zwm=$1}
        open (IN1,"<","$_");
	@IPD_ws=();$IPD_ws=0;$num_ws=0;$ave_ws=0;$ave_cr=0;$SD_sum_ws=0;@IPD_cr=();$IPD_cr=0;$num_cr=0;$SD_sum_cr=0;
        while (defined ($sequence=<IN1>)){
		if ($sequence=~/"m.+?\/(\d+)\/ccs",(\d+),(.),A,.+?,.+?,.+?,.+?,(.+?),/ && (exists $strand{$1}) && $4<$cutoff){
			if ($3==$strand{$1}){
				push (@IPD_ws,$4);
				$IPD_ws+=$4;
				$num_ws+=1;}
			else{push (@IPD_cr,$4);
                                $IPD_cr+=$4;
                                $num_cr+=1;}}}
	if ($num_ws>0 && $num_cr>0){
		$ave_ws=$IPD_ws/$num_ws;
		$ave_cr=$IPD_cr/$num_cr;
		foreach $_(@IPD_ws){
                $SD_sum_ws+=($_-$ave_ws)**2}
		foreach $_(@IPD_cr){
                $SD_sum_cr+=($_-$ave_cr)**2}
                $SD_ws=sqrt($SD_sum_ws/$num_ws);
		$SD_cr=sqrt($SD_sum_cr/$num_cr);
		print OUT1 "$zwm\t$SD_ws\t$SD_cr\n";}
	close IN1}
