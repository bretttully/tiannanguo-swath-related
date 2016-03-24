#Tiannan Guo
#tiannan.guo@gmail.com
#2012.ETH

package mzML_rtExtractPlain;
use base qw(XML::SAX::Base);
use MIME::Base64;
use Compress::Zlib;

@timeData = localtime(time);
my $timeNum=join('', @timeData);
my $randomNum=rand(100000000);
$randomNum=sprintf("%d",$randomNum);
my $rtExtractFilename="mzML_rtExtract\_$timeNum\_$randomNum.txt";

#gates
my $ifSpectrum=0;
my $ifScan=0;
my $ifBinaryDataArray=0;
my $ifBinary=0;
my $mz_or_int='NA';


#values
my $rt;
my ($mz,$mz2,$int,$int2);#binary

sub start_document{
    my ($self,$document)=@_;
    open (OUT,">$rtExtractFilename");      print "process $rtExtractFilename\n";
    print OUT "rt\tmz\tint\n";
}

sub start_element{
    my ($self,$element)=@_;
    $current_element=$element->{Name};
    my $attributes=$element->{Attributes};
    if ($current_element eq 'spectrum'){
         $ifSpectrum=1;
    }
    elsif ($current_element eq 'scan'){
            $ifScan=1;
    }
    elsif ($current_element eq 'binaryDataArray'){
            $ifBinaryDataArray=1;
    }
    elsif ($current_element eq 'binary'){
            $ifBinary=1;
    }
    elsif ($current_element eq 'cvParam'){
         if ($ifScan){
              foreach my $key (keys %$attributes){
                      my $attribute=$attributes->{$key};
                      my $name=$attribute->{Name};
                      my $value=$attribute->{Value};
                      if ($name eq 'value'){
                         $rt=$value;
                      }
              }
         }
         elsif ($ifBinaryDataArray){
              foreach my $key (keys %$attributes){
                      my $attribute=$attributes->{$key};
                      my $name=$attribute->{Name};
                      my $value=$attribute->{Value};
                      if ($name eq 'name'){
                           if ($value eq 'm/z array'){
                                $mz_or_int='mz';
                           }
                           elsif ($value eq 'intensity array'){
                                   $mz_or_int='int';
                           }
                      }
              }
         }
    }
}

sub characters{
    my ($self,$char)=@_;
    my $d=$char->{Data};
    $d=~s/\s*$//;
    $d=~s/^\s*//;
    if ($ifBinary){
         if ($mz_or_int eq 'mz'){
              $mz.=$d;

         }
         elsif ($mz_or_int eq 'int'){
                 $int.=$d;
         }
    }
}

sub end_element{
    my ($self,$element)=@_;
    my $name=$element->{Name};
    if ($name eq 'spectrum'){
         #write to OUT
         print OUT "$rt\t$mz2\t$int2\n";
         $mz='';
         $int='';
         $ifSpectrum=0;
    }
    elsif ($name eq 'scan'){
         $ifScan=0;
    }
    elsif ($name eq 'binaryDataArray'){
         $ifBinaryDataArray=0;
         $mz_or_int='NA';
    }
    elsif ($name eq 'binary'){
            $ifBinary=0;
            $mz2=&binaryRt2num($mz);
            $int2=&binaryInt2num($int);
    }

}

sub end_document{
    my $self=shift;
    my $doc=shift;
    close OUT;           #close OUT0;
    return $rtExtractFilename;
}

sub binaryRt2num{
   my $d=shift;
   my $Dd=decode_base64($d);
   my @UDd=unpack("Q*",$Dd);
   my $done=0;
   my $d2;
   while (!$done){
      my $rt=unpack("d",pack("Q",shift(@UDd)));
      $d2.="$rt,";
      if ($#UDd<=0){$done=1;}
   }
   return $d2;
}

sub binaryInt2num{
   my $d=shift;
   my $Dd=decode_base64($d);
   my @UDd=unpack("N*",$Dd);
   my $done=0;
   my $d2;
   while (!$done){
      my $int=unpack("f",pack("N",shift(@UDd)));
      $d2.="$int,";
      if ($#UDd<=0){$done=1;}
   }
   return $d2;
}

sub ms2toPeak {
   my $d=shift;
   my $ifZlib=shift;
   my $Dd=decode_base64($d);      #print OUT0 "$num,$msLevel,$ms2d\n" if ($num==12);
   $Dd=Compress::Zlib::uncompress($Dd) if ($ifZlib); #in mzXML_3.0, mz-int peaks could be compressed using Zlib.
   my @UDd=unpack("N*",$Dd);
   my $done=0;
   my $peak;
   while (!$done){
      my $mz=unpack("f",pack("I",shift(@UDd)));
      $mz=sprintf "%.4f",$mz; #changed 2011.5.17
      $peak.="  $mz ";
      my $int=unpack ("f",pack("I",shift(@UDd)));
      $int=sprintf "%.1f",$int;
      $peak.="$int\n";
      if ($#UDd<=0){$done=1;}
   }
   return $peak;
}

1;