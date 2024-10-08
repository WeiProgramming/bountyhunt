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
			if [ ! -f "$wordlist_path" ]; then
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
	echo "Processing: ${url}"
	req_res=$(curl "$url")
	
	# Make sure the folder exists
        mkdir -p results/ext
	
	#if data returned is not empty store it in a folder
	if [ -n "$req_res" ]; then
		echo "Writing data to results/ext/${url}"
		
		#sanitize url so unix doesn't misread the backslashes
		sanitized_url=$(echo $url | sed 's/[^a-zA-Z0-9]/_/g')
		
		#grep a wordlist on the data and stores into a file
		echo "$req_res" | grep --color=always -f $wordlist_path > "results/ext/${sanitized_url}.txt"
		cat results/ext/${sanitized_url}.txt
	fi
		
done < "$file_path"
