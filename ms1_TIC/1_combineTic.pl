#!/usr/bin/perl
#tiannan,2013,IMSB,ETH
use Cwd;

@f=glob("*.tic");
my $o="1R_ticAll.txt";

open(OUT,">$o");
print OUT "sample\ttic\n";

foreach (1..120){
        my @d=&oF("nci$_\_ms1.tic");
        my $d=shift @d;
        my @dd=&s($d);
        $dd[0]=~/^(.*\d+)\_ms1/;
        print OUT "$1\t$dd[1]\n";
}
close OUT;


sub getFiles{
    my $namePattern=shift;
    $namePattern=~/\.([^\.]+)$/;
    my $end=$1;
    my @files=glob("*.$end");
    my @files2;
    foreach (@files){
              if (/$namePattern/){
                    push @files2,$_;
              }
    }
    return @files2;
}

sub median{
    @_ == 1 or die ('Sub usage: $median = median(\@array);');
    my ($array_ref) = @_;
    my $count = scalar @$array_ref;
    # Sort a COPY of the array, leaving the original untouched
    my @array = sort { $a <=> $b } @$array_ref;
    if ($count % 2) {
    return $array[int($count/2)];
    } else {
    return ($array[$count/2] + $array[$count/2 - 1]) / 2;
    }
}


sub mean {
    my ($x)=@_;
    my $num = scalar(@{$x}) - 1;
    my $sum_x = '0';
    my $sum_y = '0';
    for (my $i = 1; $i < scalar(@{$x}); ++$i){
    $sum_x += $x->[$i][1];
    $sum_y += $x->[$i][2];
    }
    my $mu_x = $sum_x / $num;
    my $mu_y = $sum_y / $num;
    return($mu_x,$mu_y);
}
### ss = sum of squared deviations to the mean
sub ss {
    my ($x,$mean_x,$mean_y,$one,$two)=@_;
    my $sum = '0';
    for (my $i=1;$i<scalar(@{$x});++$i){
    $sum += ($x->[$i][$one]-$mean_x)*($x->[$i][$two]-$mean_y);
    }
    return $sum;
}
sub correlation {
    my ($x) = @_;
    my ($mean_x,$mean_y) = mean($x);
    my $ssxx=ss($x,$mean_x,$mean_y,1,1);
    my $ssyy=ss($x,$mean_x,$mean_y,2,2);
    my $ssxy=ss($x,$mean_x,$mean_y,1,2);
    my $correl=correl($ssxx,$ssyy,$ssxy);
    my $xcorrel=sprintf("%.4f",$correl);
    return($xcorrel);
}
sub correl {
    my($ssxx,$ssyy,$ssxy)=@_;
    my $sign=$ssxy/abs($ssxy);
    my $correl=$sign*sqrt($ssxy*$ssxy/($ssxx*$ssyy));
    return $correl;
}


sub oF2D{
    #usage:
    #my @d=&oF2D($in);
    #print "$d[0][0]\n";
    #
#example
#     my @d1=&oF2D($in1);
#     my @d2=&oF2D($in2);
#
#     #title
#     print OUT "$d1[0][0]";
#     foreach my $j (1..$#{$d1[0]}) {
#             print OUT "\t$d1[0][$j]";
#     }
#     print OUT "\n";
#
#
#     for my $i (1..$#d1) {
#           print OUT "$d1[$i][0]";
#           for my $j (1..$#{$d1[$i]}) {
#               $d1[$i][$j]=$d1[$i][$j]/$d2[$i][$j]*100;
#               print OUT "\t$d1[$i][$j]";
#           }
#           print OUT "\n";
#     }

    my $f=shift;
    my @d=&oF($f);
    my @d2;
    foreach my $d (@d){
            my @dd=&s($d);
            push @d2,\@dd;
    }
    return @d2;
}
sub s{
    my $a=shift;#string to be split
    my $b=shift; #saparator
                 #default is \t
    if (!$b){
        $b="\t";
    }
    my @c=split(/$b/,$a);
    return @c;
}

sub oF{
    my $file=shift;
    open (IN,$file) || die "Error: can not open $file\n";
    my @d=<IN>;
    close IN;
    foreach (@d){chomp $_;}
    return @d;
}

sub unique{
    my @a=@_;
    @a=grep(($Last eq $_ ? 0 : ( $Last=$_,1)),sort @a);
    return @a;
}

sub unique2{
    my @a=@_;
    my %a;
    foreach (@a){
              $a{$_}=1;
    }
    @a=keys %a;
    return @a;
}

sub str2array{
    my $p=shift;
    my @p;
    for (my $i=0;$i<length($p);$i++){
         push @p,substr($p,$i,1);
    }
    return @p;
}

sub printArray{
    my $r=shift;
    my @a=@$r;
    my $o=shift;
    open(OUT_printArray,">$o");
    foreach (@a){
              print OUT_printArray "$_\n";
    }
    close OUT_printArray;
}


sub printHash{
    my $r=shift;
    my %a=%$r;
    my $o=shift;
    open(OUT_printHash,">$o");
    foreach (sort {$a<=>$b} keys %a){
              print OUT_printHash "$_\t$a{$_}\n";
    }
    close OUT_printHash;
}



sub waitHr {
    my $hr=shift;
    $hr=$hr*3600;
    for (my $s=$hr;$s>0;$s--){
         print "$s of $hr\n";
         sleep(1);
    }
}

sub ave{
    my @i=@_;
    my $a=0;
    foreach (@i){$a+=$_;}
    my $n=$#i+1;
    if ($n>0){
         $a/=$n;
         $a=sprintf("%.2f",$a);
    }
    else{
         $a=$i[0];
    }
    return $a;
}

sub sd{
    my @i=@_;
    my $ave=&ave(@i);
    my $sd;
    foreach (@i){
              $sd+=($_-$ave)**2;
    }
    $sd=($sd/($#i))**0.5;
    $sd=sprintf("%.2f",$sd);
    return $sd;
}

sub sum{
    my @i=@_;
    my $a=0;
    foreach (@i){$a+=$_;}
    return $a;
}


sub dos2unix{
    my $in=shift;
    my $o=shift;
    if (!$o){
        my $o="tmp";
        open(INdos2unix,$in);
        my @d=<INdos2unix>;
        close INdos2unix;
        foreach (@d){
                  $_=~tr/\r\n//d;
        }
        open(OUTdos2unix,">$o");
        foreach (@d){
                  print OUTdos2unix "$_\n";
        }
        close OUTdos2unix;
        unlink($in);
        rename ($o,$in);
    }
    else{
        open(INdos2unix,$in);
        my @d=<INdos2unix>;
        close INdos2unix;
        foreach (@d){
                  $_=~tr/\r\n//d;
        }
        open(OUTdos2unix,">$o");
        foreach (@d){
                  print OUTdos2unix "$_\n";
        }
        close OUTdos2unix;
    }
}