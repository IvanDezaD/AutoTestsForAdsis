#!/bin/bash

#Function used to output errors (parameter wise, not script wise)
echoerr() {
	printf "[-]%s\n" "$*" >&2
}

#Function which prints the help menu of the program
printHelp() {
	echo -e "Script which runs the tests of the given practical excersise."
	echo -e "Author: Iván Deza"
	echo -e "Date: 29/02/2024"
	echo
	echo -e "Options:"
	echo -e "-p \t\tNumber of the excersise to run tests on"
	echo -e "-h \t\tPrints this help menu"
	echo -e "Example usage: ./AutoTestsP2.sh -p 2 -> Will perform the practice 2 tests"
}

#Checks the number of the practice being correct(prevents command injection through the -p parameter)
checkPractNum() {
	result="True"
	local isNumber='^[0-9]$'
	if [[ $practica =~ isNumber ]]; then
		echoerr "Expected a number and received: $practica"
		result="False"
		return #TODO, buscar la manera de quitar este return por temas de legibilidad
	fi
	if [[ $practica -ne 2 && $practica -ne 3 && $practica -ne 4 ]]; then
		echoerr "Incorrect excersise number, must be in range {2..4} and received: $practica "
		echo -e "$result"
	else
		echo -e "$result"
	fi
}

#Parameter parsing function
while getopts "hp:" opt; do
	case $opt in
	h)
		printHelp
		exit 0
		;;
	p)
		practica="$OPTARG"
		;;
	*)
		printHelp
		exit 0
		;;
	esac
done

#Function for running tests on excersise 2
pract2Tests() {
	totalErrors=0
	for i in {1..6}; do
		python3 test_practica2_$i.py &>log_pract2_$i.log
		local nErrors=$(cat log_pract2_$i.log | grep failures | awk -F "=" '{print$2}' | cut -c 1) #We take the number of errors found
		if [[ nErrors -ne 0 ]]; then
			echo -e "[-] Found error in test $i which is worth checking, log file will be saved."
			((totalErrors += 1))
		else
			rm log_pract2_$i.log
			echo -e "[+] Test $i succesfully done, log file will be deleted."
		fi
	done
	echo -e "$totalErrors"
}

#Checks path and makes sure tests are correct
checkExec() {
	valid="True"
	actualFolder=$(pwd | awk -F "/" '{print $NF}')
	testsInFolder=$(ls | grep -o "\btest.*\.py\b" | wc -l)

	#Checks that the script is in the appropiate folder
	if [[ $actualFolder != tests ]]; then
		echoerr "Expected folder to be in: tests, and we are in folder; $actualFolder, think in switching this script to the correct folder."
		valid="False"
	fi

	#Checks for the number of test files in the directory
	if [[ $testsInFolder -ne 8 ]]; then
		echoerr "Expected number of tests in the file: 8, found: $testsInFolder"
		valid="False"
	fi
	echo -e "$valid" #Devolvemos el resultado
}

#Run excersise 3 tests
pract3Tests() {
	python3 test_practica3.py &>log_pract3.log
	local nerrors=$(cat log_pract3.log | tail -n-1 | awk -F "=" '{print$2}' | cut -c 1) #Parse number of errors
	if [[ $nerrors -ne 0 ]]; then
		echo -e "[-] Found $nerrors, check the log file fot more info: log_pract3.log"
	else
		echo -e "[+] Test runned smoothly, you are safe to hand in this script"
		echo -e "[INFO] Removing log file"
		rm log_pract3.log
	fi
}

pract4Tests() {
	python3 test_practica4.py &>log_pract4.log
	local nerrors=$(cat log_pract4.log | grep failures | awk -F "=" '{print$2}' | cut -c 1) #We take the number of errors found
	local checkSshKey=$(cat log_pract4.log | tail -n-1 | cat log_pract4.log | tail -n-1 | grep -Eo '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b')
	if [[ $nerrors -ne 0 || $checkSshKey != "" ]]; then
		echo -e "[-] Found $nerrors errors, check log file for more info: log_pract4.log."
		if [[ $checkSshKey != "" ]]; then
			echo -e "Error might be something to do with the location of the ssh key, check it."
		fi
	else
		echo -e "[+] Tests runned smoothly, you are safe to hand in this script."
		echo -e "[INFO] Removed log file"
		rm log_pract4.log
	fi
}

makeTests() {
	case $practica in
	2)
		pract2Tests
		exit 0
		;;
	3)
		pract3Tests
		exit 0
		;;
	4)
		pract4Tests
		exit 0
		;;
	esac
}

main() {
	#We check if the execution is going to be succesful, in the other case we output an error and exit.
	if [[ $(checkPractNum) == "False" || $(checkExec) == "False" ]]; then
		exit 0
	fi
	makeTests
}

main
