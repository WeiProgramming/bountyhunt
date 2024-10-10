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
	
	# get the type of url ext
	ext_type=$(echo $url | sed -n 's/.*\.\([a-zA-Z0-9]*\)$/\1/p' | tr 'a-z' 'A-Z')
	
	echo $ext_type
	
	#Check if file extension exists
	case "$ext_type" in
		JS)
			echo "retrieving .js file"
			;;
		PHP)
			echo "retrieving .php file"
			;;
		ASP)
			echo "retrieving .php file"
			;;
		ASPX)
			echo "retrieving .aspx file: ${url}"
			;;
		HTML)
			echo "retrieving .html file"
			;;
		LIST)
			echo "retrieving .html file"
			;;
		SQL|DB|SQLITE|DB3)
			echo "retrieving .db file"
			ext_type="Database"
			;;
		BAK|OLD|BACKUP|SWP|SWO)
			echo "retrieving .db file"
			ext_type="Backup"
			;;
		ENV|INI|CONF|JSON|YML|YAML|XML|PLIST)
			echo "retrieving .db file"
			ext_type="CONFIG"
			;;
		LOG|OUT)
			echo "retrieving .db file"
			ext_type="LOG"
			;;
		COM)	
			echo "Discarding .com urls"
			continue
			;;
		*)	
			echo "File extension not found: ${ext_type}"
			continue
			;;
	esac
	
	echo "Processing: ${url}"
	
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
		find "${wordlist_path}/${ext_type}" -type f | while read -r vulnpath_name; do
			
			vuln_name=$(echo "$(basename "$vulnpath_name")" | sed 's/\.[^.]*$//')
			
			echo "Attempting to write data to results/${ext_type}/${vuln_name}/"
			mkdir -p results/$ext_type
			
			#grep the vuln wordlist on the data and if found, stores into a file
			if echo "$req_res" | grep --color=always -f $vulnpath_name > /dev/null; then
				
				# Make sure the folder exists
        			mkdir -p results/$ext_type/$vuln_name
        			
        			echo -e "\n\n\n\n${url}\n\n\n\n" > "results/${ext_type}/${vuln_name}/${sanitized_url}.txt";
				echo "$req_res" | grep --color=always -f $vulnpath_name >> "results/${ext_type}/${vuln_name}/${sanitized_url}.txt";
				
				cat "results/${ext_type}/${vuln_name}/${sanitized_url}.txt"
			else
				if [ -f "results/${ext_type}/valid_ext_urls.txt" ] && grep -q "${url}" "results/${ext_type}/valid_ext_urls.txt"; then
					continue
				else
					echo "Valid extension but wordlists didn't find anything, adding to results/${ext_type}/valid_ext_urls.txt" 
					echo "${url}" >> results/${ext_type}/valid_ext_urls.txt
					continue
				fi
			fi
		done
		
	fi
		
done < "$file_path"
