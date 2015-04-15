#!/usr/bin/perl
#use strict;
#use Cwd;
use File::Spec;
use warnings;

# Usage:  perl Rename.pl . w1 alexa w2 tmr

# First argument is always the directory to process
$pathtofiles = shift(@ARGV);
%channelnames = @ARGV;
$retomatch = join('|',keys(%channelnames));
opendir(DIR, $pathtofiles);
while (my $file = readdir(DIR)){
    if (  ($file =~ /_/) && ($file =~ /(.TIF|.tif|.tiff|.stk)$/) ){
	   $fextension = $1;
   } else {
	next;
   }
    if ($file =~ /($retomatch)/) {
	$channel = $channelnames{$1};
    } else {
	next;
    }
    if ($file =~ /_s([[:digit:]]*)/){
	$fieldnum = $1;
    } else {
	next;
    }
    $newname = $channel . sprintf("%03d",$fieldnum) . $fextension;
       print "$newname\n";$oldfilefull = File::Spec->catfile($pathtofiles, $file);
$newfilefull = File::Spec->catfile($pathtofiles, $newname);
    rename( $oldfilefull, $newfilefull );
}

# while (my $file = readdir(DIR))
# {
# 	if(index($file,'.TIF') != -1 && index($file,'_') != -1)
# 	{
# 		if(index($file,'w1') != -1)
# 		{
# 			$nameBase = "bright";
# 		}
# 		elsif(index($file,'w2') != -1)
# 		{
# 			$nameBase = "tmr";
# 		}
# 		elsif(index($file,'w3') != -1)
# 		{
# 			$nameBase = "cy";
# 		}
# 		elsif(index($file,'w4') != -1)
# 		{
# 			$nameBase = "alexa";
# 		}
# 		elsif(index($file,'w5') != -1)
# 		{
# 			$nameBase = "gfp";
# 		}
# 		elsif(index($file,'w6') != -1)
# 		{
# 			$nameBase = "dapi";
# 		}
# 		
# 		my $begIndex = index($file,'_s');
# 		$begIndex = $begIndex + 2;
# 		my $endIndex = index($file,'_t');
# 		$endIndex = $endIndex - 1;
# 		$length = $endIndex - $begIndex + 1;
# 		
# 		$number = substr($file,$begIndex,$length);
# 		
# 		if($number < 10)
# 		{
# 			$number = "00".$number;
# 		}
# 		elsif($number < 100)
# 		{
# 			$number = "0".$number;
# 		}
# 		$newName = $nameBase.$number.".TIF";
# 		print "$newName\n";
# 		rename($dirToGet."/".$file, $dirToGet."/".$newName);
# 	}
# }
