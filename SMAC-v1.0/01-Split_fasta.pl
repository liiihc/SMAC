$fasta="$ARGV[0]";#example: /home/user/CCS/hifi.fasta
$out_path="$ARGV[1]";#example: /home/user/CCS/ccs_reference
open (IN1,"<","$fasta");
undef %Fa;
while (defined ($_=<IN1>)){
 	if(/(>.+?)\n/){$name=$1;
  		}else{$Fa{$name}.=$_; }
		}
system "mkdir $out_path";
foreach $sequence(keys(%Fa)){
              if($sequence=~/>m.+?\/(.+?)\/ccs/){
                        $zmw=$1;
                        if ($zmw=~/^(1\d)/){
                        open (TXT,">","$out_path/$zmw.fasta");
                        print TXT "$sequence\n$Fa{$sequence}";
                }
                        elsif ($zmw=~/^(\d)/){
                        open (TXT,">","$out_path/$zmw.fasta");
                        print TXT "$sequence\n$Fa{$sequence}";
                }}}
