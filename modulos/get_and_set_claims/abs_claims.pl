#!/usr/bin/env perl
#---------------------------------------------------------------
# TO DO:
#
#---------------------------------------------------------------

#Coletor das claims

#lendo o arquivo
open(ENTRADA , "<$ARGV[0]") or die "Nao foi possivel abrir o arquivo.tmp para leitura: $!";
		
while (<ENTRADA>) { # atribui à variável $_ uma linha de cada vez
	push(@LinhasFile,$_);
}

close ENTRADA;

#obtendo das claims: O número da claim, os comentearios e a propriedade (claim)
$sizeLinhasFile = @LinhasFile;

#lista para cópia de cada bloco das claims
@cp_blk_clam = ();

for ($i=0; $i <= $sizeLinhasFile; $i++) {			
	#print $i."\n";
	
	if($LinhasFile[$i] =~ /^$/){
		$i++;			
	}
	
	if($LinhasFile[$i] =~ /(Claim.[^:]*)/){
		
		#GET - O número da claim
		$get_each_claim = $1;
		
		#GET - O número da linha onde a "claim" ocorreu
		$get_n_line_claim = "";
		
		#var que armazena os coment de cada claim
		$get_blk_coment = "";
		
		#contador de cada bloco das claims
		$cont_blk_claim = $i;		
				
		#flag para obter conteudo do bloco
		$flag_blk_claim = 1;		
		
		while ($flag_blk_claim == 1){									
			
			#a primeira vez sempre é valida
			$cont_blk_claim++;		
						
			#verifica se chegou ao fim do bloco
			if($LinhasFile[$cont_blk_claim] =~ /^$/){
					$flag_blk_claim = 0;
			}			
			
			#efetuando copia de cada linha contida no bloco da claim em questão
			push(@cp_blk_clam,$LinhasFile[$cont_blk_claim]);
		}
		
		#percorrendo bloco da claim
		#$size_cp_blk_claim = @cp_blk_clam;
				
		#obtendo os comentários do bloco da claim
		#até n-1, pois o ultimo elemento é propriedade
		for ($c=0; $c < ($#cp_blk_clam-1); $c++){
			#print $#cp_blk_clam.$c."-".$cp_blk_clam[$c];			
			#remove \n da string
			chomp($cp_blk_clam[$c]);
			
			#obtendo o número da linha onde a "claim" ocorreu
			#obtem a string "line n", o n é o numero da linha
			if($cp_blk_clam[$c] =~ /(line.[0-9]*)/){
				#obtem o número na linha
				if($1 =~ /([0-9]*$)/){
				   #linha da claim
				   $get_n_line_claim = $1;				   
				}
			}
			
			#copia os comentarios em uma unica linha
			$get_blk_coment = $get_blk_coment."//".$cp_blk_clam[$c];
		}
				
		##########################################################
		#imprime os dados coletados
		#print $get_each_claim."\n";		
		
		#coments
		#print $get_blk_coment;
		
		#A ultima linha de cada bloco das claims é a propriedade
		#print $cp_blk_clam[$#cp_blk_clam-1];		
		
		###########################################################
		#copia os dados coletados para lista auxiliar já no formato
		#para escrita no arquivo auxiliar
		#o @ é utilizar como um separador de cada item				
		$each_line_from_file = $get_n_line_claim." ; ".$get_each_claim." ; ".$get_blk_coment." ; ".$cp_blk_clam[$#cp_blk_clam-1];
		push(@lines_aux_file,$each_line_from_file);
		
		
		###########################################################
		#para evitar percorrer as linhas já lidas do bloco da claim
		$i = $cont_blk_claim;		
				
		#reiniciar o contador de bloco de cada claim
		$cont_blk_claim = 0;
		
		#reinicializando a lista
		@cp_blk_clam = ();
		#zera a variavel dos coments
		$get_blk_coment="";
	}	
				
}

#escreve os dados coletados em um arquivo auxiliar
#passar nome do arq. aux
$name_c_code="";
if($ARGV[0] =~ m/(^.[^.]*)/){
	$name_c_code=$1;
}
    
open(RESULT_ABS_P, ">$name_c_code.csv"); #open for write, overwrite

#le a lista auxiliar
foreach(@lines_aux_file){	
    
    #ESCRVEVENDO resultados das claims no arquivo 
	print RESULT_ABS_P $_;
	
}

#fechando arquivo com os resultados da propriedade abstraida
close(RESULT_ABS_P);	
