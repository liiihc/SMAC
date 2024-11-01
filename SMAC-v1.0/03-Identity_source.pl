$fasta=$ARGV[0];
$database=$ARGV[1];
$result=$ARGV[2];
$CPU=$ARGV[3];
$COV=$ARGV[4];
$IDE=$ARGV[5];
system "makeblastdb -dbtype nucl -in $database -out ${database}.blastn;blastn -max_target_seqs 1  -max_hsps 1 -query $fasta -num_threads $CPU  -db ${database}.blastn -word_size 50 -outfmt '6 qacc sacc length nident  mismatch gaps qstart qend sstart send qlen slen bitscore score evalue' > $result";
open (IN1,"<","$result");
open (OUT1,">","Full_length_ccs.txt");
open (OUT2,">","Low_quality_reads.txt");
while (defined ($_=<IN1>)){
   if ($_=~/^m.+?\/(\d+?)\/ccs\t(.+?)\t(.+?)\t(.+?)\t.+?\t.+?\t.+?\t.+?\t.+?\t.+?\t(.+?)\t.+?\t.+?\t(.+?)\t.+?\n/){
                $zmw=$1;#qacc
                $chr=$2;#sacc
                $nident=$4;#nident
                $score=$6;#score
                $length=$3;#length
                $qlen=$5;#qlen
                $ident=100*$nident/$qlen;
                $coverage=100*$qlen/$length;
                if ($coverage>=$COV && $ident>=$IDE){
                        print OUT1 "$zmw\n"}
		else {print OUT2 "$zmw\n"}}}
