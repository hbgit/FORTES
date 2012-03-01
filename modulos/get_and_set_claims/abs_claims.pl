#!/usr/bin/env perl
#---------------------------------------------------------------
# abs_claims.pl module: Gathering all claims generated by ESBMC
# Author: Herbert O. Rocha E-mail: herberthb12@gmail.com
# Version: 2 - Year: 2012
# License: GPL V3
#---------------------------------------------------------------

#Reading the file.cl with claims text
open(ENTRADA , "<$ARGV[0]") or die "Nao foi possivel abrir o arquivo.cl para leitura: $!";
		
while (<ENTRADA>) { # assigning to the variable $_ one line per time
	push(@LinhasFile,$_);
}

close ENTRADA;

#Gathering the claims: The number of the claim, comments and properties (claims)
$sizeLinhasFile = @LinhasFile;

#Creating a list to copy each claims block
@cp_blk_clam = ();

for ($i=0; $i <= $sizeLinhasFile; $i++) {			
		
	if($LinhasFile[$i] =~ /^$/){
		$i++;			
	}
	
	if($LinhasFile[$i] =~ /(Claim.[^:]*)/){
		
		#GET - The number of the claim (ID)
		$get_each_claim = $1;
		
		#GET - The line number where the claims has occurred
		$get_n_line_claim = "";
		
		#GET - Comment from the claim
		$get_blk_coment = "";
		
		#Counter of the each claims block
		$cont_blk_claim = $i;		
				
		#flag to get the contents from each claims block
		$flag_blk_claim = 1;		
		
		while ($flag_blk_claim == 1){									
			
			#the first time is always valid
			$cont_blk_claim++;		
						
			#Checking if it reached the end block
			if($LinhasFile[$cont_blk_claim] =~ /^$/){
					$flag_blk_claim = 0;
			}			
			
			#Get a copy of each claim from claims block this time
			push(@cp_blk_clam,$LinhasFile[$cont_blk_claim]);
		}
		
		#Running the claim block
						
		#Getting the comments from claim block
		#To n-1, cuz the last element is the property
		for ($c=0; $c < ($#cp_blk_clam-1); $c++){						
			#remove \n from the string
			chomp($cp_blk_clam[$c]);
			
			#Getting the line number where the claim has occurred
			#Getting the string "line n", where n is the line number
			if($cp_blk_clam[$c] =~ /(line.[0-9]*)/){
				#Getting the line number
				if($1 =~ /([0-9]*$)/){
				   #Claim line
				   $get_n_line_claim = $1;				   
				}
			}
			
			#Copying the comments in a single line
			$get_blk_coment = $get_blk_coment."//".$cp_blk_clam[$c];
		}
				
		#Copying the data gathered for an auxiliary list already on format to write it		
		#The ";" is adopting to slice each item
		$each_line_from_file = $get_n_line_claim." ; ".$get_each_claim." ; ".$get_blk_coment." ; ".$cp_blk_clam[$#cp_blk_clam-1];
		push(@lines_aux_file,$each_line_from_file);
				
		#Avoiding to run the lines already in the claim block
		$i = $cont_blk_claim;		
				
		#reset the counter for each claim block
		$cont_blk_claim = 0;
		
		#reset the list
		@cp_blk_clam = ();
		#reset the comments variable
		$get_blk_coment="";
	}	
				
}

#Writting the data gathered an temporary file
$name_c_code="";
if($ARGV[0] =~ m/(^.[^.]*)/){
	$name_c_code=$1;
}
    
open(RESULT_ABS_P, ">$name_c_code.csv"); #open for write, overwrite

#Reading the auxiliary list
foreach(@lines_aux_file){	
    
    #Writting the data gathered an temporary file
	print RESULT_ABS_P $_;
	
}

#close the temporary file
close(RESULT_ABS_P);	
