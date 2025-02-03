#!/bin/bash

jdir="/marconi/home/userexternal/jciarlo0/regcm_tests/Atlas2/"

for f in ./*; do 
	echo "checking $f file..."
	echo $f >> diff.txt
	diff $f $jdir$f >> diff.txt
	#if [ $f != "./replace_ICT22.sh" ]; then
		#sed -i 's/ICT22/ICT23/' $f
	#fi
done

