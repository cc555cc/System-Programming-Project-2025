#!/bin/bash

target_directory="${1:-.}"
echo "$target_directory"
if [ ! -d "$target_directory" ]; then
	echo "The directory you entered does not exist"
	exit 0
else 
	echo "Directory Watcher is now running..."
fi

# destination file:

file="directory_change_log_$(date +%F).json"

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
	echo "$entry"
done

	
