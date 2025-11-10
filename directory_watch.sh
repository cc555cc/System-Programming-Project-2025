#!/bin/bash

if [ "$PPID" -eq 1 ]; then

else #when the script is ran manually
	#the directory where the user n the script manually
	initial_directory="$pwd"

	#make directory for log file if it doesn't exist
	mkdir -p "${initial_directory}/Directory_Watcher_Log"

	# log destination file:
	file="${initial_directory}/Directory_Watcher_Log/directory_change_log.json"
fi

#first argument as the directory to monitor
target_directory="${1:-.}"

#check directory validity
if [ ! -d "$target_directory" ]; then
	echo "The directory you entered does not exist"
	exit 0
else 
	echo "Directory Watcher is now running..."
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

	
