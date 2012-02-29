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
#TO DO: REMOVE pre_code.c <- temporary file
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
DIR_ABS_CLAIMS_FUNC=modulos/get_and_set_claims/abs_claims_func.pl
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
		#preprocessing the C program that will be analysed
		#$1 -> source code name; $2 function name if there is.
		exec_processadorc $1 $2		
	else
		echo "No <$1> found - Please try again" 		
	fi	
}
#./uncrustify -q -l C -c ben.cfg -f ../ccode_here/testCode.c
exec_processadorc()
{	
	#verifying if there is a directory in the path' code	
	name_program=$(echo $1 | grep -o "[^/]*$")	
	rec_file="pre_$name_program"
	rec_path=$(echo $1 | sed "s/$name_program/$rec_file/g") 
	
	$DIR_PROC_PRIMARY -q -l C -c $CONFIG_CFG -f $1 > $rec_path
	#$DIR_PROC_AUX $DIR_NEWCODEPROC/$rec_file -> need to solve the bug with a[2]={1,2}
	#call ESBMC to get the claims-> <location of the pre-processed code(URL)> <only the code name>
	#$2 function name if there is.			
	call_esbmc_claims $rec_path $name_program $2
		
}


call_esbmc_claims()
{		
	if [ $# -eq 2 ];
	then
		#no function in arg to apply it
		#generating an internal extension (.cl -> claims) from original code		
		var=$2
		pattern='^.[^.]*'
		if [[ $var =~ $pattern ]];
		then
			#.cl -> claims
			rec_name=${BASH_REMATCH[0]}".cl"
		fi
			
		#Running the ESBMC to get the claims
		esbmc --64 --no-library --show-claims $1 > $DIR_RESULT_CLAIMS/$rec_name			
		
		#Call the function that running the abstraction method to get data from claims	
		# $rec_name -> file.cl; $1 -> code path; $2 -> code name
		
		call_abs_claims "$rec_name" "$1" "$2"
		
	else		
		#function in arg to apply it		
		#generating an internal extension (.cl -> claims) from original code				
		rec_name_function_abs=$3
		
		valid_func=`cat $1 | grep -c "$rec_name_function_abs(.*)"`
		
		if [ $valid_func -ge 1 ];
		then			
			var=$2
			pattern='^.[^.]*'
			if [[ $var =~ $pattern ]];
			then
				##.cl -> claims		
				rec_name=${BASH_REMATCH[0]}"_func_"$rec_name_function_abs".cl"
				#Running the ESBMC to get the claims
				esbmc --64 --no-library --function $rec_name_function_abs --show-claims $1 > $DIR_RESULT_CLAIMS/$rec_name
				#Call the function that running the abstraction method to get data from claims	
				call_abs_claims "$rec_name" "$1" "$rec_name_function_abs" "$2"
			fi
		else
			echo "This name function: <$rec_name_function_abs> is not a valid function in the code!"
		fi	
		
	fi	
}

#Call the method that gatherig all data in the claims shown by ESBMC
call_abs_claims(){
				
	#generating an internal extension (.abs) for abstraction from claims	
	var_code=$1
	pattern_2='^.[^.]*'
	if [[ $var_code =~ $pattern_2 ]];
	then
		#.cl -> claims		
		rec_name_2=${BASH_REMATCH[0]}".csv"
	fi
	
	#getting the claims from function
	#ABS_CLAIMS receves as input all claims	
	if [ $# -eq 2 ];
	then
		#All claims
		$DIR_ABS_CLAIMS $DIR_RESULT_CLAIMS/$1
		get_and_set_claims "$rec_name_2" "$2" "$3"
	else
		#based on function, where $3 is function name		
		$DIR_ABS_CLAIMS_FUNC $DIR_RESULT_CLAIMS/$1 $3
		get_and_set_claims "$rec_name_2" "$2" "$4"
	fi
	
}

get_and_set_claims(){			
	#$1 -> list claims; $2-> path pre-processing code; $3 -> code name	
	tmp_path=$(echo $2 | sed "s/pre_$3/new_$3.tmp/g")
	out=`$DIR_GET_AND_SET_CLAIMS $1 $2 $tmp_path`
	
	#if the out == 1 there are not claims
	rec_out=`echo $out | grep -c "1"`
	
	if [ $rec_out -eq 0 ];
	then
		#applying last formatting due to possible inclusion of new lines in the code		
				
		#call the end preprocessing		
		$DIR_PROC_PRIMARY -q -l C -c $CONFIG_CFG -f  $tmp_path 
		rm $tmp_path 		
	else
		echo "There are not claims for this functions!"
	fi	
}

clean(){
	
	gt_file=$(ls $DIR_RESULT_CLAIMS/)
	if [ -n "$gt_file" ]; 
	then
		rm $DIR_RESULT_CLAIMS/*
	fi	
}

#------------------------------ end functions -------------------------

#------------------------------   main    -----------------------------
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
	start_program ${!#} $arg_f 
elif [ $# -ge 1 ]
then
	start_program $1
fi
#------------------------------   main    -----------------------------
