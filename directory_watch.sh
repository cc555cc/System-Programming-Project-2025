#!/bin/bash

#first argument as the directory to monitor
target_directory="${1:-.}"
target_directory="$(realpath "$target_directory")"
#check directory validity
if [ ! -d "$target_directory" ]; then
	echo "The directory you entered does not exist, exiting..."
	exit 1
fi

filename="$2"; #name of the output file

#if 2nd argument is not valid, set a default value
if [[ ! "$2" =~ ^[a-zA-Z0-9._-]+$ ]]; then
  echo "Warning: Invalid or missing file name for log output, using default name...";
  filename="$(basename "$(realpath "$target_directory")")_change_log.json";
fi

#define the directory where the user run the script manually
initial_directory="$(pwd)"

#setup a directory for log file if it doesn't exist
mkdir -p "${initial_directory}/Directory_Watcher_Log"

# define the log folder in the log directory:
file="${initial_directory}/Directory_Watcher_Log/$filename"

echo "";

#===logging logic===
/usr/bin/inotifywait -m -r -e create -e modify -e delete -e move \
	--format '%T|%w%f|%e' --timefmt '%F %T' "$target_directory" | while IFS="|" read DATE FILE EVENT
do	
	#entry sanitization for JSON format: turns " to \" and \ to \\
	sanitized_file_name=$(printf '%s' "$FILE" | sed 's/\\/\\\\/g; s/"/\\"/g')
	
	#echo the event
	echo "$DATE File: $sanitized_file_name $EVENT";	
	entry=$(cat <<EOF
{
	"timestamp": "$DATE",
	"file": "$sanitized_file_name",
	"event": "$EVENT"
},
EOF
)
	
	#insert json object to output destination file
	echo "$entry" >> "$file"
done

	
