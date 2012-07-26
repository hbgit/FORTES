#!/bin/bash

#Settings for FORTES tool
#==========================================

#Getting absolute PATH

#ABS_PATH_FORTES
tmp1=`pwd`

#check path
cd $tmp1
list_file=`ls config.sh | wc -l`
if [ $list_file -ge 1 ];
then	
	echo "Running startup-config..."
	tr1=`echo $tmp1 | sed s,/,\\\\\\\\\/,g`	
	cat fortes | sed -e "s/ABS_PATH_FORTES=\"\[<??>\]\"/ABS_PATH_FORTES=$tr1/g" > out.tmp
	rm fortes
	cat out.tmp > fortes
	chmod +x fortes
	rm out.tmp
	echo "   >> Status: OKAY"
else	
	echo "Sorry, you are outside from the directory where the FORTES tool was extracted. See README file."
fi



#==========================================
