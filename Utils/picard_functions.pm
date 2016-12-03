# FileName : picard_functions.pm
# Author : Miriam Rubio
# Description : Interface to Picard functions.

#!/usr/bin/perl
use strict;
use FindBin qw($Bin);
use lib "$Bin";

package picard_functions;

# Function: reorder
# This function reorders reads in a SAM/BAM file to match the contig ordering
# in a provided reference file, as determined by exact name matching of contigs.
# $picardPath: string. path to picardTools.
# $file_in: Input file
# $file_out: Output file
# $javaram:Configuration Ram size
# $genomeref: Reference genome.
sub reorder($$$$$){
	my ($picardPath,$file_in,$file_out,$javaram,$genomeref) = @_;
	(-e $file_in) or die "\n reorder:: $file_in not found";
	system("time java  $javaram -jar $picardPath/ReorderSam.jar I= $file_in O= $file_out REFERENCE= $genomeref VALIDATION_STRINGENCY=LENIENT");
	if ($? == -1) {
 		print "failed to execute: $!\n";
		exit;
 	}else{
		print "\n $file_out file done!";
	}
}

# Function: picardBam2Bai
# Generates a BAM index (.bai) file.
# $picardPath: string. path to picardTools.
# $javaram:Configuration Ram size
# $file_in:Input file name.
# $file_out:Output file name.
sub picardBam2Bai($$$$){
	my ($picardPath,$file_in,$file_out,$javaram) = @_;
	(-e $file_in) or die "\n picardBam2Bai:: $file_in not found";
	system("java $javaram -jar $picardPath/BuildBamIndex.jar INPUT=$file_in OUTPUT=$file_out VALIDATION_STRINGENCY=LENIENT");
	if ($? == -1) {
 		print "failed to execute: $!\n";
		exit;
 	}else{
		print "\n $file_out file done!";
	}
}

# Function: picardSort
# This function sorts the input SAM or BAM.
# $picardPath: string. path to picardTools.
# $javaram:Configuration Ram size
# $file_in:Input file name.
# $file_out:Output file name.
sub picardSort($$$$){
	my ($picardPath,$file_in,$file_out,$javaram) = @_;
	(-e $file_in) or die "\n picardSort:: $file_in not found";
	print "\nSorting $file_in";
	system("java $javaram -jar $picardPath/SortSam.jar INPUT=$file_in OUTPUT=$file_out SORT_ORDER=coordinate VALIDATION_STRINGENCY=LENIENT");
	print"\n java $javaram -jar $picardPath/SortSam.jar INPUT=$file_in OUTPUT=$file_out SORT_ORDER=coordinate VALIDATION_STRINGENCY=LENIENT";
	if ($? == -1) {
 		print "failed to execute: $!\n";
		exit;
 	}else{
		print "\n $file_out file done!";
	}
}

# Function: markDuplicates
# Examines aligned records in the supplied SAM or BAM file to locate duplicate molecules.
# All records are then written to the output file with the duplicate records flagged.
# $picardPath: string. path to picardTools.
# $javaram:Configuration Ram size
# $file_in: bam input file
# $file_out: bam output file
# $file_met:Metrics file

sub markDuplicates($$$$$$){
	my ($picardPath,$file_in,$file_out,$file_met,$remove,$javaram) = @_;
	(-e $file_in) or die "\n markDuplicates:: $file_in not found";
	my $removeDup = "";
	print "\nmarkDuplicates $file_in";
	if ($remove ==1){
		$removeDup ="REMOVE_DUPLICATES=true"
	}
	my $command = "java $javaram -jar $picardPath/MarkDuplicates.jar INPUT= $file_in OUTPUT= $file_out METRICS_FILE= $file_met $removeDup VALIDATION_STRINGENCY=LENIENT";
	print "\n Command: $command";
	system($command);
	if ($? == -1) {
 		print "failed to execute: $!\n";
		exit;
 	}else{
		print "\n $file_out file done!";
	}
}



# Function: validateSamFile
# Read a SAM or BAM file and report on its validity.
# $picardPath: string. path to picardTools.
# $javaram:Configuration Ram size
# $file_in:Input file name.
# $file_out:Output file name.
sub validateSamFile($$$$){
	my ($picardPath,$file_in,$file_out,$javaram) = @_;
	print"\n Validate file $file_in";
	(-e $file_in) or die "\n validateSamFile:: $file_in not found";
	system("java  $javaram -jar $picardPath/ValidateSamFile.jar INPUT= $file_in OUTPUT= $file_out IGNORE_WARNINGS=true MODE=SUMMARY MAX_OUTPUT=1000 VALIDATE_INDEX=true");
	if ($? == -1) {
 		print "failed to execute: $!\n";
		exit;
 	}else{
		print "\n $file_out file done!";
	}
}

# Function: mergeBamFiles
# Read a SAM or BAM file and report on its validity.
# $picardPath: string. path to picardTools.
# $javaram:Configuration Ram size
# $file_in1:Input bam file name.
# $file_in2:Input bam file name.
# $file_out:Output file name.
sub mergeBamFiles($$$$$){
	my ($picardPath,$file_in1,$file_in2,$file_out,$javaram) = @_;
	((-e $file_in1)&&(-e $file_in2)) or die "\n mergeBamFiles:: $file_in1 or $file_in2 not found";
	system("java  $javaram -jar $picardPath/MergeSamFiles.jar INPUT= $file_in1 INPUT= $file_in2 OUTPUT= $file_out CREATE_INDEX=True VALIDATION_STRINGENCY=LENIENT");
	if ($? == -1) {
 		print "failed to execute: $!\n";
		exit;
 	}else{
		print "\n $file_out file done!";
	}
	unlink($file_in1);
	unlink($file_in2);
}

# Function: addGroupToBam
# Replaces all read groups in the INPUT file with 
# a new read group and assigns all reads to this read group in
# the OUTPUT BAM.
# $picardPath: string. path to picardTools.
# $javaram: Ram size
# $file_in:Input bam file name.
# $file_out:Output file name.
# $group_id: Group name.
# $library: Library name.
# $platform: Platform.
# $sample_name:Sample_name.
sub addGroupToBam($$$$$$$$){
	my ($picardPath,$file_in,$file_out,$group_id,$library,$platform,$sample_name,$javaram) = @_;
	(-e $file_in) or die "\n addGroupToBam:: $file_in not found";
	system("java  $javaram -jar $picardPath/AddOrReplaceReadGroups.jar INPUT=$file_in  OUTPUT=$file_out RGID=$group_id RGLB=$library RGPL=$platform RGSM=$sample_name RGPU=AA CREATE_INDEX=True VALIDATION_STRINGENCY=LENIENT");
	unlink($file_in);
	$file_in =~ s/\.bam/\.bai/;
	unlink($file_in);
	if ($? == -1) {
 		print "failed to execute: $!\n";
		exit;
 	}else{
		print "\n $file_out file done!";
	}
}

# Function: BamToFastQ
# Extracts read sequences and qualities from the input SAM/BAM 
# file and writes them into the output file in Sanger fastq format. 
# $picardPath: string. path to picardTools.
# $javaram:Configuration Ram size
# $file_in:Input bam seed file name:filename without .fastq suffix.
# $type: 1(single-end) 2 (paired-end)

sub BamToFastQ($$$$){
	my ($picardPath,$file_in,$type,$javaram) = @_;
	(-e $file_in) or die "\n BamToFastQ:: $file_in not found";
	if ($file_in =~ m{(.+)\.bam$}){
		my $file_out = $1.".fastq";
		my $file_out1 = $1."_1.fastq";
		my $file_out2 = $1."_2.fastq";
		if ($type == 1){
		        system("java  $javaram -jar $picardPath/SamToFastq.jar INPUT=$file_in FASTQ=$file_out VALIDATION_STRINGENCY=LENIENT");
		}elsif($type == 2){
			system("java  $javaram -jar $picardPath/SamToFastq.jar INPUT=$file_in FASTQ=$file_out1 SECOND_END_FASTQ=$file_out2 VALIDATION_STRINGENCY=LENIENT");
		}
		unlink($file_in);
		if ($? == -1) {
 			print "failed to execute: $!\n";
			exit;
 		}else{
			print "\n $file_out file done!";
		}	
	}
	
}

# Function: MarkDuplicates
# Examines aligned records in the supplied SAM or BAM file to locate duplicate molecules.
# All records are then written to the output file with the duplicate records flagged 
# $picardPath: string. path to picardTools.
# $javaram:Configuration Ram size
# $mDFileIn: .bam file in.
# $dataOutDir: path to output directory 
# $sample: sample seed
# $project_id: Project identifier
# $javaram:Ram size

sub markDuplicatesPhase($$$$$$$){
	my ($picardPath,$mDFileIn,$dataOutDir,$sample, $project_id, $remove,$javaram) = @_;
	my $file_out = $dataOutDir.$project_id."_".$sample."_MD.bam";
	my $file_outindx = $dataOutDir.$project_id."_".$sample."_MD.bai";
	my $file_met = $dataOutDir.$project_id."_".$sample."_MD_metrics.txt";
	print"\n MarkDuplicates phase $mDFileIn";
	markDuplicates($picardPath,$mDFileIn,$file_out,$file_met,$remove,$javaram);
	picardBam2Bai($picardPath,$file_out,$file_outindx,$javaram);
	#unlink($mDFileIn);
	$mDFileIn =~ s/\.bam/\.bai/;
	#unlink($mDFileIn);
}

# Function: validatePhase
# Read a SAM or BAM file and report on its validity.
# $picardPath: string. path to picardTools.
# $javaram:Configuration Ram size
# $valFileIn: .bam file in.
# $dataOutDir: path to output directory 
# $sample: sample seed
# $project_id: Project identifier
# $javaram:Ram size
sub validatePhase($$$$$$){
	my ($picardPath,$valFileIn,$dataOutDir,$sample, $project_id, $javaram) = @_;
	my $valFileOut=$dataOutDir.$project_id."_".$sample."_validation.txt";
	validateSamFile($picardPath,$valFileIn,$valFileOut,$javaram)
}


1
