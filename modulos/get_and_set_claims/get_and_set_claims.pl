#!/usr/bin/env perl

#---------------------------------------------------------------
# TO DO: pre-processamento de código
# Doing: 
# Objetivo: inserir as assertivas com as claims
# Herbert O. Rocha
#--------------------------------------------------------------- 


#dir resutl_claims
$dir_result_claims = "result_claims/".$ARGV[0];

#inicialização da flag do assert
$flag_assert = 0;

#diretorio do código C analisado

#$dir_c_code = "modulos/preprocessador/c_code.pre";
$dir_c_code = $ARGV[1];

#checking if is the claims to apply
$if_blank=`cat $dir_result_claims | wc -l`;
if($if_blank == 0){
	print "NO CLAIMS!!!";
	exit;
}


#lendo o arquivo com as informações abstraidas do resultado das claims
open(ENTRADA , "<$dir_result_claims") or die "Nao foi possivel abrir o arquivo.tmp para leitura: $!";
		
while (<ENTRADA>) { # atribui à variável $_ uma linha de cada vez
	push(@LinhasFile_abs,$_);
}

close ENTRADA;


# obtendo o nome do arquivo C
# e lendo o código C original
$name_c_code="";
@linhas_c_code="";
if($ARGV[0] =~ m/(^.[^.]*)/){
	$name_c_code=$1;

	#leitura do código C analisado	já pré-processado	
	#PATH do código C analisado
	#$path_c_code = $dir_c_code."/"."pre_".$name_c_code.".c";
	$path_c_code = $dir_c_code;
	#print $path_c_code."\n";
	
	open(C_CODE , "<$path_c_code") or die "Nao foi possivel abrir o arquivo.c para leitura: $!";
		
	while (<C_CODE>) { # atribui à variável $_ uma linha de cada vez
		#verificando se já existe a biblioteca <assert.h>
		if($_ =~ m/(<assert.h>)/){
			#flag demarcando que existe a biblioteca no código
			$flag_assert = 1;
		}
		push(@linhas_c_code,$_);
	}

	close C_CODE;	 

	
}	



# criação do novo codigo C
# e inserção das ASSERTS
$new_name_code_path = "new_code/new_".$name_c_code.".c";

#abrindo o novo code C para escrever e inserir a assertiva
#*** Open file ***
#open(NEW_FILEC , ">$new_name_code_path") or die "Nao foi possivel abrir o novo new_arquivo.c: $!";
$size_new_file_inst = @linhas_c_code;


# leitura do vetor com as linhas do arquivo ".abs" com
# as propriedades abstraidas das CLAIMS

#lista auxiliar utilizada para receber as Nº CLAIMS verificadas para inserção
#no código
@rec_ns_claims_verified=();
#lista auxiliar Coments
@rec_claims_Coments_verified=();
#lista aux property
@rec_claims_properties_verified=();
#lista aux line number of claim
@rec_claims_line_n_verified=();

$size_line_file_abs = @LinhasFile_abs;

for ($i=0; $i <= $size_line_file_abs; $i++) {
	#print $LinhasFile_abs[$i]."-".$i."\n";
	#@rec_each_line = split(/@/,$LinhasFile_abs[$i]);
	@rec_each_line = split(/;/,$LinhasFile_abs[$i]);
	
	#verificação caso exista diretivas para uso de expressões boolenas
	#como as exibidas pelas "claims"
	if($rec_each_line[-1] =~ /(.*FALSE.*|.*TRUE.*)/){
		#verificando se faz parte do código		
		if($1 =~ m/[^FALSE  TRUE]/){
			#print $1."\n";
			#$i++;
			next;
		}
		#então a condição isolada de avaliação é das claims
		else{
			#$i++;
			next;
		}		
	}
	#verificando propriedades que "ainda" não são tratadas para a utilização
	#direta nas assertivas
	elsif($rec_each_line[-1] =~ m/(!tmp\$.|SAME-OBJECT|INVALID-POINTER|POINTER_OFFSET)/){		
		next;		
	}
	else{
		#propriedades validadas para a criação das assertivas
		#atribuindo as variaveis os valores correspondentes
		#($num_line_claim,$num_claim,$coment_claim,$property_claim) = @rec_each_line;
		
		push(@rec_claims_line_n_verified,$rec_each_line[0]);
		push(@rec_ns_claims_verified,$rec_each_line[1]);
		push(@rec_claims_Coments_verified,$rec_each_line[2]);
		push(@rec_claims_properties_verified,$rec_each_line[3]);	
		
		
	}
	
}


#manipulação do código para inserção das ASSERTS
#percorrendo o código e contando as linhas do código

#contador do somatorio para acompanhar o incremento das linhas
#i=0 -> Sn=(i=0+1)+(i=1+1)+(i=2+1), sempre ,um incremento a mais na linha a ser manipulada
$sn_i=0;

#print $rec_claims_line_n_verified[$cont]."\n";
#verificando se a biblioteca do ASSERT existe
#para inserir a biblioteca do assert
if($flag_assert != 1){									
	#print NEW_FILEC "#include \"CUnit/Basic.h\" //-> by FORTES \n";				
	print"#include \"CUnit/Basic.h\" //-> by FORTES \n";				
	#agora já existe a assertiva
	$flag_assert = 1;
	$sn_i=$sn_i+1;	
}


#contador para a lista de número de linhas
$cont_line=0;	
for($cont=0;$cont<$size_new_file_inst; $cont++){				
			
	#verifica se a linha foi identificada na analise com ESBMC
	#e consta no arquivo ".abs"
	#o menos 1 no ($num_line_claim-1) é devido ao vetor iniciar em 0
	#ou seja se a linhas for 1 no vetor será a posição do contador é 0
	#logo 1-1=0
	#elsif($cont == ($rec_claims_line_n_verified[$cont]-1)+$sn_i){
	#print $cont."-".$rec_claims_line_n_verified[$cont_line]."\n";		
	if($cont == ($rec_claims_line_n_verified[$cont_line]-1)+$sn_i){		
				
		#escreve a ASSERTIVA e os comentarios NO CÓDIGO
		#remover \n
		chomp($rec_claims_properties_verified[$cont_line]);
		chomp($rec_ns_claims_verified[$cont_line]);
		
		#<to_do> tratar comentários obter apenas o necessario
		chomp($rec_claims_Coments_verified[$cont_line]);
		
		#remove espaços em branco
		$rec_claims_properties_verified[$cont_line]=trim($rec_claims_properties_verified[$cont_line]);
		#finalmente escreve no arquivo
		#print NEW_FILEC "CU_ASSERT($rec_claims_properties_verified[$cont_line]); //-> $rec_ns_claims_verified[$cont_line]::$rec_claims_line_n_verified[$cont_line]->by FORTES \n";
		print "CU_ASSERT($rec_claims_properties_verified[$cont_line]); //-> $rec_ns_claims_verified[$cont_line]::$rec_claims_line_n_verified[$cont_line]->by FORTES \n";
		#print $rec_claims_properties_verified[$cont_line];
		
		#testo para a proxima posição verificando se ela possue o 
		#numero da linha
		$cont_line = $cont_line+1;
		while($cont == ($rec_claims_line_n_verified[$cont_line]-1)+$sn_i){
			#remover \n
			chomp($rec_claims_properties_verified[$cont_line]);
			chomp($rec_ns_claims_verified[$cont_line]);
		
			#<to_do> tratar comentários obter apenas o necessario
			chomp($rec_claims_Coments_verified[$cont_line]);
		
			#remove espaços em branco
			$rec_claims_properties_verified[$cont_line]=trim($rec_claims_properties_verified[$cont_line]);
			#finalmente escreve no arquivo		
			#print NEW_FILEC "CU_ASSERT($rec_claims_properties_verified[$cont_line]); //-> $rec_ns_claims_verified[$cont_line]::$rec_claims_line_n_verified[$cont_line]->by FORTES \n";
			print "CU_ASSERT($rec_claims_properties_verified[$cont_line]); //-> $rec_ns_claims_verified[$cont_line]::$rec_claims_line_n_verified[$cont_line]->by FORTES \n";
			
			$cont_line = $cont_line+1;			
			
		}		
		
	}
	
	
			
	#print NEW_FILEC $linhas_c_code[$cont];
	print $linhas_c_code[$cont];
	#print $cont."-> ".$New_File_inst[$cont];	
			
}

#*** Close the file ***
close(NEW_FILEC);

#funções uteis
#remove espaços em branco
sub trim {
  my $string = shift;
  for ($string) {
    s/^\s+//;
    s/\s+$//;
  }
  return $string;
}


