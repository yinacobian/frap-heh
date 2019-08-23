#Version : 09/07/2017
#heh-db.pl creates an index for a database in fasta format [db.fasta] with the specified length [k-mer size]

#heh-db.pl [db.fasta] [k-mer size] 

#$ARGV[0]  = db.fasta
#$ARGV[1] = k-mer size 
use Storable;
my $db_id = (split(/\./,$ARGV[0]))[0];
my $ksize = $ARGV[1];


#..1.. make database fasta file a file with the genome in one line 
#cat all_viruses.fna | perl -ne 'unless ($_=~/^\>/) {chop;} print $_;'| perl -ne ' $_=~s/(?<=.)\>/\n\>/g; print $_; END{print "\n"} ' 

my %todo;
my $count = 0;

open (DB, "$ARGV[0]");
$/="\n>";
foreach (<DB>) {
    $_=~s/^>//;
    chomp;
    my @fields=split(/\n/,$_);
    my $head=shift @fields;
    my @id=split(/\s/,$head);
    my $db_id=shift @id;
    my $seq=join('',@fields);
    my $genomelength=length $seq;
    my $stop = $genomelength - $ksize;
    for (my $i=0;$i<=$stop;$i++){
        my $kmer=substr($seq,$i,$ksize);
        if (exists $todo{$kmer}){
            $todo{$kmer}= "$todo{$kmer},$db_id";
        } else {
            $todo{$kmer}="$db_id";
        }
    }
    $count++;
    print "done genome $count\n" if ($count%500==1);
}
$/="\n";
close (DB);

#open (DB_INDEX, ">index2-$ksize-$db_id.tab");
#while( my( $key, $value ) = each %todo ){
#    print DB_INDEX "$key\t$value\n";
#}
#close (DB_INDEX);
store \%todo, 'index2-$ksize-$db_id.tab';

