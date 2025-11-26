#!/bin/bash

# checks system for inotifywait availability
if ! command -v inotifywait &> /dev/null; then
	echo "Error: inotifywait is not installed. Please install inotify-tools package."
	echo "Run: sudo apt install inotify-tools"
	exit 1
fi

#first argument as the directory to monitor
target_directory="${1:-.}"
target_directory="$(realpath "$target_directory")"
#check directory validity
if [ ! -d "$target_directory" ]; then
	echo "The directory you entered does not exist, exiting..."
	exit 1
fi

# checks for read perms of the target directory
if [ ! -r "$target_directory" ]; then
	echo "Error: No read permission for '$target_directory'"
	exit 1
fi

filename="$2"; #name of the output file

# checking if the user gave us a name for the log file.
# this version allows for spaces in the filename
if [[ ! "$2" =~ ^[a-zA-Z0-9._\ -]+$ ]]; then
  echo "Warning: Invalid or missing file name for log output, using default name...";
  filename="$(basename "$(realpath "$target_directory")")_change_log.json";
fi

#define the directory where the user run the script manually
initial_directory="$(pwd)"

#setup a directory for log file if it doesn't exist
mkdir -p "${initial_directory}/Directory_Watcher_Log"

# checks for write perms of the log directory
if [ ! -w "${initial_directory}/Directory_Watcher_Log" ]; then
	echo "Error: No write permission for '${initial_directory}/Directory_Watcher_Log'"
	exit 1
fi

# define the log folder in the log directory:
file="${initial_directory}/Directory_Watcher_Log/$filename"

echo "";

#===logging logic===
/usr/bin/inotifywait -m -r -e create -e modify -e delete -e move \
	--exclude 'Directory_Watcher_Log' \
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
}
EOF
)
	
	#insert json object to output destination file
	echo "$entry" >> "$file"
done

	
