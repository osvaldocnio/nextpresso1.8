#!/usr/bin/perl -w

# xmlParRNAseq.pm
# Author: Osvaldo Graña
# Description : RNA-seq analysis branch
# 
# v0.1		9feb2013


package xmlParRNAseq;

use strict;
use FindBin qw($Bin);
use XML::Simple;
use XML::Validator::Schema;
use lib "$Bin";


sub getDataFromConfigXMLdocument($){
	my ($elemento) = shift;		
	
	my $hashRef=printElement("Init",$elemento,"");
	
;}

sub processXML($$){
	my ($XMLschema, $XMLdocument) = @_;
	
	if (!(-e $XMLschema)){
		print STDERR "\n ERROR processXML::$XMLschema does not exist";
		exit(-1);
	}
	if (!(-e $XMLdocument)){
		print STDERR "\n ERROR processXML::$XMLdocument does not exist";
		exit(-1);
	}
	
#	my $fileConfig = xmlPar::XMLParser($configXMLSchema,$configXMLDocument);

 
	# valida el documento XML con el schema
	my $validator = XML::Validator::Schema->new(file => $XMLschema);
	my $parser = XML::SAX::ParserFactory->parser(Handler => $validator);
	eval { $parser->parse_uri($XMLdocument) };
	die "File failed validation: $@" if $@;
	my $hashRef = XMLin($XMLdocument, forcearray=>1);
	
	#use Data::Dumper;
	#print STDERR "FILE:\n".Dumper($fileConfig)."\n";
	
#	my $outputConfig = getDataFromConfigXMLdocument($fileConfig);# recibe como argumento una referencia a la hash
	

	
#	my $fileexperiment = xmlPar::XMLParser($experimentXMLSchema, $experimentXMLDocument);
#	my $outputConfig = getDataFromConfigXMLdocument($fileConfig);
#	my $output_params = validateXML($file);
	return $hashRef;
}


#sub printElement ($$$){
#      my $nombre=shift;
#      my $elemento=shift;
#      my $indentacion=shift;
#      #print $elemento."\n";		
#      print $indentacion . "Elemento: " . $nombre . "\n";
#      $indentacion .= "\t";
#
#      foreach my $clave (keys %$elemento) { 
#	      if(ref $elemento->{$clave} eq "ARRAY"){
#		      foreach my $subelemento (@{$elemento->{$clave}}) {
#			      if (ref $subelemento eq "HASH") {
#				      printElement($clave, $subelemento,$indentacion);
#	        	      }else {
#				      print $indentacion . "Elemento: " . $clave . ", Valor: " . $subelemento . "\n";
#        		      }
#		      }		
#	      }else {
#		      print $indentacion . "Atributo: " . $clave . " Valor: " . $elemento->{$clave} . "\n";
#	       }
#      }
#      
#      return ($elemento);
#}

1; # tells perl that the module was correctly loaded


