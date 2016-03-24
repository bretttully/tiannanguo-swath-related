#!/usr/bin/perl
#tiannan,2012,IMSB,ETH
use Cwd;
use XML::SAX;
use XML::Simple;
use mzML_rtExtractPlain;

$mzMLfile=shift; #"kidTis5_15.mzML";
if (!$mzMLfile){
    my @f=glob("*.mzML");
    foreach my $f (@f){
            if ($f=~/\d+\.mzML/){    print "process $f\n";
                 $mzMLfile=$f;
                 #mzML to mzML.txt
                 my $mzMLtxtFile=&mzMLfile_to_mzMLtxt($mzMLfile);
            }
    }
}
else{
     #mzML to mzML.txt
     my $mzMLtxtFile=&mzMLfile_to_mzMLtxt($mzMLfile);
}

sub mzMLfile_to_mzMLtxt{
    my $f=shift;
    my $outFile=$f."\.txt";
    my $d=XML::SAX::ParserFactory->parser(Handler=>mzML_rtExtractPlain->new)->parse_uri($f);
    rename($d,$outFile);
    return $outFile;
}