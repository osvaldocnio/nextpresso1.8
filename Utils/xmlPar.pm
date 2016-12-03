#!/usr/bin/perl

# FileName :xmlPar.pm
# Author : Miriam Rubio
# Description: XML parser functions.

package xmlPar;

use strict;
use FindBin qw($Bin);
use XML::LibXML qw(XML_ELEMENT_NODE);
use lib "$Bin";

# Function: validateSRA
# This method validates a given XML document against the corresponding
# SRA Schema given as its basename
sub validateSRA($$) {
	my($schemaFile, $doc) = @_;

	# Now, let's get an object to be used to validate
	my $xmlschema = XML::LibXML::Schema->new( location => $schemaFile );
		
	# Let's validate!
	$xmlschema->validate($doc);
}


# Function: XMLParser
sub XMLParser($$){
    my ($schemaFile,$xml_file) = @_;
    	
	my $parser = new XML::LibXML;		
	my $struct = $parser -> parse_file($xml_file);
	validateSRA($schemaFile,$struct);
	my $rootel = $struct -> getDocumentElement();
	my @kids = $rootel -> childNodes();
    	my %experiment = ();
	foreach my $child(@kids) {
		if ($child -> nodeType() == XML_ELEMENT_NODE){
        	my $elname = $child -> nodeName();
        	my $val = $child -> textContent();
			if (exists($experiment{$elname})){
				$experiment{$elname} .= ",$val";
			}else{
				$experiment{$elname} = $val;
			}
			
          	       	
		}
		
	}
	#print join(" ",keys(%experiment)); 
	return \%experiment;
}
# Function: templateParser
sub templateParser($){
	my ($filein) = @_;
	local *FDin;
	open (FDin , "<".$filein) or die "Error opening $filein";
	my %template = ();
	while(<FDin>){
		chomp;
		if ($_ !~ /^(\s*$|#)/){
			my (@fields) = split("\t",$_);
			if (scalar(@fields)>=3){
				$template{$fields[0]} = {							
							TYPE => $fields[1],		
							OPT =>	$fields[2],	
						 	};
				if(scalar(@fields)==4){
					$template{$fields[0]}{DEFAULT} = $fields[3];	
				}
			}else{
				print "templateParser: Error parsing $fields[0] $filein\n";
				exit();
			}

		}
	}
	close FDin;
	return \%template;
	
}
# Function: validateXML
sub validateXML($$){
	my ($experiment,$template) = @_;
	foreach my $key (keys(%{$template})){
		if (exists(${$experiment}{$key})){
			my @values = split(",",${$experiment}{$key});
			if (scalar(@values) == 0){
				print "\nERROR validateXML: Empty value in $key\n";
				exit();
			}
			foreach my $value (@values){
				if (${$template}{$key}{TYPE} =~ /file/i){
					(-e $value) or die "validateXML: File $value does not exist";
				}elsif(${$template}{$key}{TYPE} =~ /directory/i){
					(-d $value) or die "validateXML: Directory $value does not exist";
				}	
				elsif ( $value !~ /^${$template}{$key}{TYPE}$/i){
					print "validateXML: Wrong value in $key: $value";
					exit();
				}
			}
						
		}elsif (${$template}{$key}{OPT} =~ /Y/i){
			if (exists(${$template}{$key}{DEFAULT})){
				 ${$experiment}{$key} = ${$template}{$key}{DEFAULT};
			}else{
				 ${$experiment}{$key} = "";
			}
		}else{
			print "validateXML: Missing mandatory field $key\n";
		}
		print "$key: ${$experiment}{$key}\n";
	}
	return $experiment;	
}
# Function: processXML
sub processXML($$$){
	my ($schemaFile,$file_in,$template_in) = @_;
	if (!(-e $schemaFile)){
		print STDERR "\n ERROR processXML::$schemaFile does not exist";
		exit();
	}
	if (!(-e $file_in)){
		print STDERR "\n ERROR processXML::$file_in does not exist";
		exit();
	}
	if (!(-e $template_in)){
		print STDERR "\n ERROR processXML::$template_in does not exist";
		exit();
	}
	my $file1 = XMLParser($schemaFile,$file_in);
	my $template1 = templateParser($template_in);
	my $output_params = validateXML($file1,$template1);
	return $output_params;
}

1


