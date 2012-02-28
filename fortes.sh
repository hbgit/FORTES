#!/bin/bash
#---------------------------------------------------------------------
# FORTES tool - FORTES - FORmal unit TESt generation
#---------------------------------------------------------------------
# Goal: This tool aims to create Test Cases based on claims from ESBMC 
#		model checker
# Author: Herbert O. Rocha E-mail: herberthb12@gmail.com
# Version: 2 - Year: 2012
# License: GPL V3	
# STATUS: NOKAY
#---------------------------------------------------------------------

#--------------------------------------------------------------------
#settings preprocessador
CONFIG_CFG=modulos/preprocessador/pre_processamento_primario/ben.cfg
DIR_PROC_PRIMARY=modulos/preprocessador/pre_processamento_primario/uncrustify
DIR_PROC_AUX=modulos/preprocessador/aux_pre_processamento/aux_formatation.pl
DIR_NEWCODEPROC=modulos/preprocessador/c_code.pre
#--------------------------------------------------------------------

#--------------------------------------------------------------------
#settings for get and set claims
DIR_RESULT_CLAIMS=result_claims
DIR_ABS_CLAIMS=modulos/get_and_set_claims/abs_claims.pl
DIR_GET_AND_SET_CLAIMS=modulos/get_and_set_claims/get_and_set_claims.pl
#--------------------------------------------------------------------

DIR_RESULT_END_CODE=new_code

#------------------------------ functions ---------------------------
#get file that will be analised
start_program()
{	
	clear
	#Verifying the C program	
	if [ -e "$1" ]; 
	then
		echo "######################################################"
		echo "---------------- FORTES (Beta) v2 ----------------"
		echo "--------------------------------------------------"
		echo " " 
		echo "ANSI-C program: $1"
		echo " " 
		echo "--------------------------------------------------"
		
		#preprocessing the C program that will be analysed
		#$1 -> file.c and $2 -> function/claim file
		#exec_processadorc $1 $2					
		exec_processadorc $1
		
	else
		echo "No <$1> found - Please try again" 		
	fi	
}
#./uncrustify -q -l C -c ben.cfg -f ../ccode_here/testCode.c
exec_processadorc()
{
			
	echo ""
	echo "-> Starting the process of pre-processing code"
	echo "-> File: $1"
	#verifying if there is a directory	
	name_program=$(echo $1 | grep -o "[^/]*$")	
	rec_file="pre_$name_program"
	rec_path=$(echo $1 | sed "s/$name_program/$rec_file/g") #to apply a new FORTES version
	
	
	#$DIR_PROC_PRIMARY -q -l C -c $CONFIG_CFG -f $1 > $DIR_NEWCODEPROC/$rec_file
	$DIR_PROC_PRIMARY -q -l C -c $CONFIG_CFG -f $1 > $rec_path
	#$DIR_PROC_AUX $DIR_NEWCODEPROC/$rec_file -> need to solve the bug with a[2]={1,2}
	#call ESBMC to get the claims-> <location of the pre-processed code(URL)> <only the code name>
	#call_esbmc_claims "$DIR_NEWCODEPROC/$rec_file" "$name_program"	
	call_esbmc_claims "$rec_path" "$name_program"	#to apply a new FORTES version
	#call_esbmc_claims "$rec_path" "$2"	#to apply a new FORTES version
		
}


call_esbmc_claims()
{
	echo ""	
	echo "-> Call ESBMC to get all the claims"		
	
	GET_func=($(ctags -x --c-kinds=f $1 | grep -o "^[^ ]*"))
	
	#Getting the total number of function in the C program
	FUNC_total=`echo ${GET_func[*]} | wc -w`
	
	#name function for next step
	rec_name_function_abs=""
	
	cont=0
	while [ $cont -lt $FUNC_total ]; 
	do
		if [ ${GET_func[$cont]} == "main" ];
		then
			cont=`expr $cont + 1`
		else			
			#generating an internal extension (.cl -> claims) from original code		
			echo "From function: "${GET_func[$cont]}
			rec_name_function_abs=${GET_func[$cont]}
			
			var=$2
			pattern='^.[^.]*'
			if [[ $var =~ $pattern ]];
			then
				##.cl -> claims		
				rec_name=${BASH_REMATCH[0]}"_func_"${GET_func[$cont]}".cl"
				#Running the ESBMC to get the claims
				esbmc --no-library --function ${GET_func[$cont]} --show-claims $1 > $DIR_RESULT_CLAIMS/$rec_name
				#Call the function that running the abstraction method to get data from claims	
				call_abs_claims "$rec_name" "$1" "$rec_name_function_abs"
			fi
			#echo $rec_name	
			
			cont=`expr $cont + 1`
		fi
		
	done
	
}

#Chama o método para abstração dos dados das claims
call_abs_claims(){
	echo ""
	echo "-> Abstraction claims"	
	#generating an internal extension (.abs) for abstraction from claims	
	var_code=$1
	pattern_2='^.[^.]*'
	if [[ $var_code =~ $pattern_2 ]];
	then
		#.cl -> claims
		#rec_name_2=${BASH_REMATCH[0]}".abs"
		rec_name_2=${BASH_REMATCH[0]}".csv"
	fi
	
	#getting the claims from function
	#ABS_CLAIMS as input all claims
	
	$DIR_ABS_CLAIMS $DIR_RESULT_CLAIMS/$1 $3
	
	
	#Question to keep going
	echo "Do you want to keep going with the run method? Type y (yes) or n (No), followed by [ENTER]:"
	read choose
	if [ $choose = "y" ];
	then		
		get_and_set_claims "$rec_name_2" "$2"	
	else
		echo "Executin oborted!!!!"
		exit
	fi
	
}

get_and_set_claims(){
	echo ""	
	echo "-> Get and Set claims on C code"			
	out=`$DIR_GET_AND_SET_CLAIMS $1 $2`
	
	#if the out == 1 there are not claims
	rec_out=`echo $out | grep -c "1"`
	
	if [ $rec_out -eq 0 ];
	then
		#applying last formatting due to possible inclusion of new lines in the code		
		rec_var_1=$1
		pattern_rec='^.[^.]*'
		if [[ $rec_var_1 =~ $pattern_rec ]];
		then
			#.cl -> claim
			rec_get="new_"${BASH_REMATCH[0]}".c"
		fi
		
		#call the preprocessing
		$DIR_PROC_PRIMARY -q -l C -c $CONFIG_CFG -f  $DIR_RESULT_END_CODE/$rec_get > $DIR_RESULT_END_CODE/"mf_"$rec_get
		rm $DIR_RESULT_END_CODE/$rec_get 
		echo "-> Method Fortes applied."
		echo ""
		echo "-> The new code with asserts is here:" 
		echo "   $DIR_RESULT_END_CODE/mf_$rec_get"
		echo "--------------------------------------------------"
	else
		echo "There are not claims for this functions!"
	fi
	
	
	echo ""
	echo "######################################################"	
}

clean(){
	
	gt_file=$(ls $DIR_RESULT_CLAIMS/)
	if [ -n "$gt_file" ]; 
	then
		rm $DIR_RESULT_CLAIMS/*
	fi
	
	gt_file=$(ls $DIR_NEWCODEPROC/)
	if [ -n "$gt_file" ]; 
	then
		rm $DIR_NEWCODEPROC/*
	fi
	
	gt_file=$(ls $DIR_RESULT_END_CODE/)
	if [ -n "$gt_file" ]; 
	then
		rm $DIR_RESULT_END_CODE/*
	fi	
	
}

#------------------------------ end functions -------------------------

#------------------------------   main    -----------------------------
clear
if [ $# -ge 1 ];
then	
	while getopts  "hcf:" flag
	do		
		case "${flag}" in
			h) 
				received_h=1			
			;;
			c) 
				received_c=1						
			;;
			f) 
				received_f=1
				arg_f="${OPTARG}"				
			;;	
			*) 
			echo "Sorry, there isn't this option!"
			exit 1;
			;;		
		esac
	done	
else
	echo "Please provide a C program to apply - fortes <file.c> or usage fortes -h"
fi

#Checking the options
if [ ${received_h} ]
then
			echo ""
			echo "------------------------------  FORTES (Beta) v2 ---------------------------"
			echo "		  .-."
			echo "		  /v\\"
			echo "		 // \\\\    > L I N U X - GPL<"
			echo "		/(   )\\"
			echo "		 ^^-^^"
			echo "-----------------------------------------------------------------------------"
			echo "Usage:                    Purpose:"
			echo ""
			echo "fortes [-h]               Show help"						
			echo "fortes \"<file.c>\"         Source file - Default: Based on all claims, "
			echo "                          adopting the following ESBMC options:"			
			echo "                          esbmc --64 --no-library --show-claims <\$file.c>"						
			echo "_____________________________________________________________________________"
			echo "Additonal options:"
			echo ""
			echo "fortes [-c]              "
			echo "        Clean all folders (old results)"
			echo "fortes [-f] \"<options>\" \"<file.c>\" "						
			echo "        User can set main function name"
			echo ""
			echo "-----------------------------------------------------------------------------"
			exit 1;
elif [ ${received_c} ]
then
	echo "Do you want to clean all folders (old results)? Type y (yes) or n (No), followed by [ENTER]:"
	read choose
	if [ $choose = "y" ];
	then
		echo "> Cleaning all folders"
		clean
	fi
	#exit 1;	
elif [ ${received_f} ]
then
	#for while just print the function name
	echo $arg_d
elif [ $# -ge 1 ]
then
	start_program $1
#else
#then
	#echo "Please provide a C program to apply - fortes <file.c> or usage fortes -h"
fi
#------------------------------   main    -----------------------------
