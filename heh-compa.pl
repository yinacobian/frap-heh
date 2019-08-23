#Version : 09/07/2017
#heh-compa.pl reads the index [index-k-d.tab] get length of the k, same as db [k-mer size] get the reads to compare [reads.fasta]

my $db_id = (split(/\./,$ARGV[0]))[0];
my $reads_id = (split(/\./,$ARGV[1]))[0];


#..2.. open reads file and compare to the oneline database, save results in a hash 

my %index;
open (INDEX, "$ARGV[0]");
while (<INDEX>) {
    chomp;
    my @fields=split;
    $index{$fields[0]}=$fields[1];
} 
close(INDEX);

open (READS, "$ARGV[1]");


#..3.. count the unique and repeated hits and print two different lists
$/="\n>";

my $count = 0;
my %unico; #hash where key is the genome id and contents are the unique hits
my %repetido; #hash where key is the genome id and contents are all hits (unique and repeated)

while (<READS>) {
    $_=~s/^>//;
    chomp;
    my @fields=split(/\n/,$_);
    my $head=shift @fields;
    my $seq=join('',@fields);
    my $part=substr($seq,0,$ARGV[2]);
    if (exists $index{$part}) {
        print "$head has a hit $part  $index{$part}\n";
        my @ids = split (/,/,$index{$part});
        my $num_hits = scalar @ids;
        if ($num_hits == 1) {
            if (exists $unico{$ids[0]}){
                $unico{$ids[0]}++;
            }    else {
                $unico{$ids[0]}=1;
            }
        }   
        foreach my $j (@ids){
            if (exists $repetido{$j}){
                $repetido{$j}++;
            } else {
                $repetido{$j}=1;
            }
        }
    }
$count++;
print "done read $count\n" if ($count%500==1);
}
$/="\n";

#while( my( $key, $value ) = each %hits ){
#    print "$key:$value\n";
#}

close (READS);



open (HITS_UNICO, "> heh-hitunico-vs-$db_id-$reads_id.tab");
while( my( $key, $value ) = each %unico ){
    print HITS_UNICO "$value\t$key\n";
}
close (HITS_UNICO);

open (HITS_REPETIDO, "> heh-hitrepetido-vs-$db_id-$reads_id.tab");
while( my( $key, $value ) = each %repetido ){
    print HITS_REPETIDO "$value\t$key\n";
}
close (HITS_REPETIDO);
