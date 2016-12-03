#!/usr/bin/perl
$!=1;
# FileName :formatsConversion.pm
# Author : Miriam Rubio
# Description:

use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin";
use lib "$Bin/..";
use Utils::filesFunc;
use File::Basename;

package formatsConversion;

	
# Function: bam2Bed
# This function converts a .bam file to .bed file using bedtools
# $BEDtoolsPath:Path to bedtools
# $file_in:complete path to input bam file
	 
sub bam2Bed($$){
	my ($BEDtoolsPath,$file_in)= @_;
	(-e $file_in) or die "\n bam2Bed:: $file_in not found";
	if($file_in =~ m{(.+)\.bam$}){
		my $file_out = $1.".bed";
		print "\n bam2Bed $file_in";
		system("\n time $BEDtoolsPath/bamToBed -i $file_in > $file_out") == 0 or die "bam2Bed:: $file_in to Bed failed : $?";
		print "\n $file_out file done!";
		print "\n End bam2Bed $file_in";
		return $file_out;
	}else{
		print "\n Error bam2Bed: incorrect input file name";
		exit(-1);
	}	
} 



sub wig2Bed($$){
	my ($file_in, $outpuDir) = @_;
	local *FDin;
	local *FDout;
	(-e $file_in) or die "\n wig2Bed:: File $file_in does not exist";
	(-d $outpuDir) or die "\n wig2Bed:: Directory $outpuDir does not exist";
	my $file_in_basename = File::Basename::basename($file_in);	
	if ($file_in_basename =~ m{(.+)\.wig$}){	
		my $file_out = $outpuDir."/".$1.".bed";
		(open(FDin , "<".$file_in)) or die "\nwig2Bed:: File $file_in cannot open $!";
		(open(FDout , ">".$file_out)) or die $!;		
		print "\n Converting $file_in to BED format";
		#my $passheader = 0;
		my $chrom = "";
		my $step = "";
		my $start = "";
		my $span = 1;
		my $stepType = -1; # 1: variableStep; 2: fixedStep; -1: Error
		my $line ="";
		
		#while ($passheader == 0){
		while (<FDin>){
			$line = $_;
			chomp $line;			
			if ($line !~ /track/){
				if ($line =~ /variableStep\s+chrom=([^\s]+)(.*)/){
					$chrom = $1;
					$stepType = 1;
					#$passheader = 1;
					if ($2 =~ /span=([^\s]+)/){
						$span = $1;
					}
					print "\n variableStep";
				}elsif ($line =~ /fixedStep\s+chrom=([^\s]+)\s+start=([^\s]+)\s+step=([^\s+])/){
					$chrom = $1;
					$start = $2;
					$step = $3;
					$stepType = 2;
					#$passheader = 1;
					print "\n fixedStep";
				}else{
					if ($stepType == 1){
					($line =~ /\s*([^\s]+)\s+([^\s]+)/) or die "\n wig2Bed:: Bad Format line $line";				
					for (my $i=0; $i<$span; $i++){
						my $pos = $1 + $i;
						my $posAnt = $pos - 1;
						print FDout "\n$chrom\t$posAnt\t$pos\tNA\t$2";
					}
					}elsif ($stepType == 2){
						($line =~ /\s*([^\s]+)\s*/) or die "\n wig2Bed:: Bad Format line $line";
						my $posAnt = $start - 1;
						print FDout "\n$chrom\t$posAnt\t$start\tNA\t$1";
						$start += $step;
				
					}else{
						print STDERR "\n wig2Bed::Bad stepType";
						exit(-1);
					}
				}
			}
			
		}
		close(FDin);
		close(FDout);
		
	}else{
		print "\nwig2Bed:: File $file_in does not have .wig extension";
		exit();
	}
}


1




