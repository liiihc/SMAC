$sam_path = $ARGV[0];
$fasta_path = $ARGV[1];
$bam_path = $ARGV[2];
$mapped_bam_path = $ARGV[3];
$csv_path = $ARGV[4];
$CPU = $ARGV[5];
open (IN,"<","$ARGV[6]");
while (defined ($_=<IN>)){
	if ($_=~/(\d+)/){
		$HASH{$1}=1}}
@sam = glob("$sam_path/*.sam");

system "mkdir -p $bam_path $mapped_bam_path $csv_path";

my $processes = 0;

foreach my $sam (@sam) {
    $sam =~ /\/(\d+).sam/;
    my $zmw = $1;
if (exists $HASH{$zmw}){
    while ($processes >= $CPU) {
        wait();
        $processes--;
    }
    my $pid = fork();
    if (!defined $pid) {
        die "No process: $!";
    } elsif ($pid == 0) {
        system "samtools view -bS $sam -o $bam_path/${zmw}.bam";
	system "samtools faidx $fasta_path/${zmw}.fasta";
        system "pbmm2 align --preset SUBREAD $fasta_path/${zmw}.fasta $bam_path/${zmw}.bam $mapped_bam_path/${zmw}_mapped.bam -j 1";
        system "pbindex $mapped_bam_path/${zmw}_mapped.bam";
        system "ipdSummary $mapped_bam_path/${zmw}_mapped.bam --reference $fasta_path/${zmw}.fasta --identify m6A --methylFraction --csv $csv_path/${zmw}.csv";
        exit(0);  
    } else {
        $processes++;
    }
}}

while ($processes > 0) {
    wait();
    $processes--;
}

