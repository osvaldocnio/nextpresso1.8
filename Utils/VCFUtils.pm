# FileName : VCFUtils.pm
# Author : Miriam Rubio
# Description : VCF Files functions

use strict;
use warnings;

package VCFUtils;

# Function: combineVcf
# Description:Combines multiple records into a single one; if sample names overlap then they are uniquified.
# $dataDir: Path to data directory
# $samples: array reference to the samples list
# $gatkpath: path to GATK tools
# $genomeref: Reference genome.
# $javaram: Ram size
# $project_id: Project's name
#java -Xmx2g -jar GenomeAnalysisTKLite.jar \
#   -R ref.fasta \
#   -T CombineVariants \
#   --variant input1.vcf \
#   --variant input2.vcf \
#   -o output.vcf \
#   -genotypeMergeOptions UNIQUIFY

sub combineVcf($$$$$){
	my ($samples,$outfile,$javaram, $gatkpath, $genomeref) = @_;
	my $merged = "";
	foreach my $samp (@{$samples}){
		$merged .=" --variant ".$samp;
	}
	my $command = "java $javaram -jar $gatkpath/GenomeAnalysisTKLite.jar  -R $genomeref -T CombineVariants $merged -o $outfile -genotypeMergeOptions UNSORTED";
	system($command) == 0 or die "combineVcf:: $outfile can't be created : $?";
}


# Function: SelectVariantsVcf
# Description:Select only SNP or Indel variants.
# $inputFile: VCF input file.
# $type: SNP or INDEL
# $gatkpath: path to GATK tools.
# $genomeref: Reference genome.
# $javaram: Ram size
#
# java -Xmx2g -jar GenomeAnalysisTKLite.jar \
#   -R ref.fasta \
#   -T SelectVariants \
#   --variant input.vcf \
#   -o output.vcf \
#   -selectType INDEL

sub SelectVariantsVcf($$$$$){
	my ($inputFile,$javaram, $gatkpath, $genomeref, $type) = @_;
	if (-e $inputFile){
               $inputFile =~ /(.+)\.vcf/;
               my $outFile = $1.".Selected".$type.".vcf";
               my $command = "java $javaram -jar $gatkpath/GenomeAnalysisTKLite.jar  -R $genomeref -T SelectVariants --variant $inputFile -o $outFile -selectType $type";
	       system($command) == 0 or die "SelectVariantsVcf:: $outFile can't be created : $?";
               return  $outFile;
	}else{
		print STDERR "\n SelectVariantsVcf::$inputFile does not exist";
		exit(-1);
	}
}

1

