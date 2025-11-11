#!/bin/bash

#first argument as the directory to monitor
target_directory="${1:-.}"
#check directory validity
if [ ! -d "$target_directory" ]; then
	echo "The directory you entered does not exist"
	exit 0
else 
	echo "Directory Watcher is now running..."
fi


if [ "$PPID" -eq 1 ]; then
	file
else #when the script is ran manually
	#define the directory where the user run the script manually
	initial_directory="$pwd"

	#setup a directory for log file if it doesn't exist
	mkdir -p "${initial_directory}/Directory_Watcher_Log"

	# define the log folder in the log directory:
	file="${initial_directory}/Directory_Watcher_Log/directory_change_log.json"

	#auto start configuration
	read -p "would you like the script to run automatically on startup?(y/n)" input
	input="${input,,}"

	if [["$input" -eq "y"]]; then
		#define script address
		file_address = "${initial_directory}/directory_watch.sh"
		target_directory = "${initial_directory}/${target_directory}"
		
		break
	else if [["$input" -eq "n"]]; then
		echo "skipping cron setup"
		break
	else
		echo "invalid input, please enter y or n"
	fi
fi

#===logging logic===
inotifywait -m -r -e create -e modify -e delete -e move \
	--format '%T|%w%f|%e' --timefmt '%F %T' "$target_directory" | while IFS="|" read DATE FILE EVENT

do
	#entry sanitization for JSON format: turns " to \" and \ to \\
	sanitized_file_name=$(printf '%s' "$FILE" | sed 's/\\/\\\\/g; s/"/\\"/g')
	sanitized_event=$(printf '%s' "$EVENT" | sed 's/\\/\\\\/g; s/"/\\"/g')

	entry=$(cat <<EOF
{
	"timestamp": "$DATE",
	"file": "$sanitized_file_name",
	"event": "$sanitized_event"
}
EOF
	)
	
	#insert json object to output destination file
	echo "$entry" >> "$file"
done

	
