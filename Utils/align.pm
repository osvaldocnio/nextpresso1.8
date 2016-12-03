#!/usr/bin/perl
# FileName : align.pm
# Author : Osvaldo Grana
# Description: performs aligning of read files
# v0.1		21abr2014

use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin";


package align;

sub buildIndex($$$){
	my ($bowtiePath,$referenceFasta,$indexPrefixForReferenceSequence)=@_;
	
	my $command=$bowtiePath."bowtie-build ".$referenceFasta." ".$indexPrefixForReferenceSequence;
	print "\n\t[executing] ".$command."\n";	
	system($command);
}
		
sub doAligning($$$$$$$$$$$$$$$$$$$$$$$$$$){

	my($tophatPath,$bowtiePath,$samtoolsPath,
	$referenceSequence,$indexPrefixForReferenceSequence,$GTF,$nTophatThreads,$maxMultihits,
	$readMismatches,$segmentLength,$segmentMismatches,$spliceMismatches,$reportSecondaryAlignments,
	$bowtieVersion,$readEditDist,$readGapLength,$mateInnerDist,$mateStdDev,$pairedEnd,$solexaQualityEncoding,
	$libraryType,$coverageSearch,$performFusionSearch,$inputFile,$output,$useGTF)=@_;
	
	use Env qw(PATH);
	#$PATH.=":".$bowtiePath.":".$samtoolsPath;
	#$ENV{'PATH'}.=":".$bowtiePath.":".$samtoolsPath;
	
	my $command="export PATH=\$PATH:".$bowtiePath.":".$samtoolsPath."; ".$tophatPath."tophat ";
	
	if($bowtieVersion eq "1"){
		$command.="--bowtie1 ";
	}
	
	$command.="-p ".$nTophatThreads." --read-edit-dist ".$readEditDist." ";	
	$command.="--read-gap-length ".$readGapLength." ";

	if(defined($solexaQualityEncoding)){
		if($solexaQualityEncoding eq "solexa"){ #sanger quals
			$command.="--solexa-quals ";
		}elsif($solexaQualityEncoding eq "solexa1.3"){
			$command.="--solexa1.3-quals ";
		}
	}
	
	if($useGTF eq "true" && defined($GTF) && $GTF ne ""){
		$command.="--GTF ".$GTF." ";
	}
	
	if($coverageSearch ne ""){
		$command.=$coverageSearch." ";
	}
	
	$command.="--max-multihits ".$maxMultihits." ";
	
	if(lc($reportSecondaryAlignments) eq "true"){
		$command.="--report-secondary-alignments ";
	}
	
	if(lc($pairedEnd) eq "true"){
		$command.="--mate-inner-dist ".$mateInnerDist." --mate-std-dev ".$mateStdDev." ";
	}
	
	if(lc($performFusionSearch) eq "true"){
		$command.="--fusion-search ";
	}
	
	#posibilities: unstranded, firststrand, secondstrand	
	if(lc($libraryType) eq "unstranded"){
		$command.="--library-type fr-unstranded ";
	}elsif(lc($libraryType) eq "firststrand"){
		$command.="--library-type fr-firststrand ";
	}elsif(lc($libraryType) eq "secondstrand"){
		$command.="--library-type fr-secondstrand ";
	}
	
	$command.="--read-mismatches ".$readMismatches." --segment-mismatches ".$segmentMismatches." --segment-length ".$segmentLength." ";
	$command.="--splice-mismatches ".$spliceMismatches." -o ".$output." ".$indexPrefixForReferenceSequence." ".$inputFile;
	
	print "\n\t[executing] ".$command."\n";	
	system($command);
	
	#creates bam file index (bai)
	$command="export PATH=\$PATH:".$bowtiePath.":".$samtoolsPath."; ";
	$command.="samtools index ".$output."/accepted_hits.bam";

	print "\n\t[executing] ".$command."\n";	
	system($command);	
}

sub getTophatAligningStatistics($){
#returns the content of the 'align_summary.txt' generated by tophat for the entered sample
	my($file)=@_;
	
	#use File::List;
 	#my $search = new File::List($alignmentsOutputDirectory.$file."/logs/");
  	#$search->show_empty_dirs();                   # toggle include empty directories in output
  	#my @bowtieFiles=@{ $search->find("^bowtie") }; # finds all lines starting with bowtie

	my @justTheFileName=split('/',$file);
	my $output=$justTheFileName[@justTheFileName-1]."\n\n";

	open(IN,$file."/align_summary.txt");
	foreach my $line(<IN>){
			$output.=$line;
	}
		
	close(IN);
	
	$output.="\n\n------------------------------------------------------------------------------------------------------\n\n";	
	
	return($output);
	
}

sub convertBAMtoBED($$$$){
#receives a bam file and converts it to bed file with bedtools
#the new file is saved in the $annotationsDir
	my($bedtoolsPath,$alignmentsOutputDirectory,$annotationsDir,$file)=@_;

	my $command=$bedtoolsPath."bamToBed -i ".$alignmentsOutputDirectory.$file."/accepted_hits.bam > ".$annotationsDir.$file.".bed";

	print "\n\t[executing] ".$command."\n";	
	system($command);
	
}

sub runPeakAnnotator($$$$$){
#receives a path for PeakAnnotator, a bed file with aligned reads, a GTF file with annotations, an output directory, a prefix for the output files

	my($peakAnnotatorPath,$bedFile,$GTF,$annotationsDir,$prefix)=@_;

	use Env qw(PATH);
	#$PATH.=":".$peakAnnotatorPath;
	#$ENV{'PATH'}.=":".$peakAnnotatorPath;
	
	my $command="export PATH=\$PATH:".$peakAnnotatorPath."; java -jar ".$peakAnnotatorPath."PeakAnnotator.jar -p ".$bedFile." -a ".$GTF." -o ".$annotationsDir." -x ".$prefix. " -g all -u NDG";

	print "\n\t[executing] ".$command."\n";	
	system($command);
	
}

1
