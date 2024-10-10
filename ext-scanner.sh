#!/bin/bash

file_path=""
wordlist_path=""

#check flags
while [[ $# -gt 0 ]]; do
	case "$1" in
		-l)
			file_path="$2"
			#checks if these if file list exists
			if [ ! -f "$file_path" ]; then
				echo "File list: ${file_path} doesn't exist"
				exit 1
			fi
			shift 2
			;;
		-w)
			wordlist_path="$2"
			 #checks if these if wordlist exists 
			if [ ! -d "$wordlist_path" ]; then
				echo "Wordlist: ${wordlist_path} doesn't exist"
				exit 1
			fi
			shift 2
			;;
		*)
			echo "Invalid argument: $arg"
			exit 1
			;;
	esac
done

while IFS= read -r url; do
	ext_type=""
	vuln_name=""
	
	# this variable will hold the path to the urls that curl can't reach not sure why 
	unreachable_url=""
	
	# get the type of url ext
	ext_type=$(echo $url | sed -n 's/.*\.\([a-zA-Z0-9]*\)$/\1/p' | tr 'a-z' 'A-Z')
	
	echo $ext_type
	case "$ext_type" in
		JS)
			echo "retrieving .js file"
			;;
		PHP)
			echo "retrieving .php file"
			;;
		*)	
			echo "File extension not found"
			continue
			;;
	esac
	
	echo "Processing: ${url}"
	mkdir -p results/$ext_type
	
	req_res=$(curl "$url")
	
	# Curl sometimes call to make the proper call 
	curl_exit_status=$?
	
	echo $curl_exit_status
	
	if [ $curl_exit_status -eq 0 ]; then
  		echo "curl was successful"
	elif [ $curl_exit_status -eq 6 ]; then
  		echo "curl error: Could not resolve host"
	elif [ $curl_exit_status -eq 7 ]; then
  		echo "curl error: Failed to connect to host"
	else
  		echo "curl error: Exit code $curl_exit_status saving data url to results/${ext_type}"
  		echo "$url" >> results/$ext_type/unreachable.txt
  		continue
	fi
	
	#sanitize url so unix doesn't misread the backslashes for output
	sanitized_url=$(echo $url | sed 's/[^a-zA-Z0-9]/_/g')
	
	#if data returned is not empty store it in a folder
	if [ -n "$req_res" ]; then
		
		# Go through the vulnerable wordlist directory and get the vuln name
		find "${wordlist_path}/${ext_type}/Vulnerabilities" -type f | while read -r vulnpath_name; do
			
			vuln_name=$(echo "$(basename "$vulnpath_name")" | sed 's/\.[^.]*$//')
			
			echo "Writing data to results/${ext_type}/${vuln_name}/"
			
			#grep the vuln wordlist on the data and if found, stores into a file
			if echo "$req_res" | grep --color=always -f $vulnpath_name > /dev/null; then
				
				# Make sure the folder exists
        			mkdir -p results/$ext_type/$vuln_name
        			
				echo "$req_res" | grep --color=always -f $vulnpath_name > "results/${ext_type}/${vuln_name}/${sanitized_url}.txt";
				cat "results/${ext_type}/${vuln_name}/${sanitized_url}.txt"
			else
				continue
			fi
		done
		
	fi
		
done < "$file_path"
