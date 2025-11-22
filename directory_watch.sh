#!/bin/bash
#first argument as the directory to monitor
target_directory="${1:-.}"
#check directory validity
if [ ! -d "$target_directory" ]; then
	echo "The directory you entered does not exist"
	exit 1
fi

#when script is ran by crontab
if [ "$CRON" = "1" ]; then
	sleep 10
	echo "crontab run";
	target_directory="$1"
	mkdir -p "$2/Directory_Watcher_Log"
	basename="$(basename "$1")"
	file="$2/Directory_Watcher_Log/${basename}_change_log.json"
else #when the script is ran manually
	echo "manual run"
	#define the directory where the user run the script manually
	initial_directory="$(pwd)"

	#setup a directory for log file if it doesn't exist
	mkdir -p "${initial_directory}/Directory_Watcher_Log"

	#extract name of target_directory
	dirname="$(basename "$target_directory")"

	# define the log folder in the log directory:
	file="${initial_directory}/Directory_Watcher_Log/${dirname}_change_log.jsonl"

	#auto start configuration
	read -p "would you like the script to run automatically on startup?(y/n)" input
	input="${input,,}"

	if [[ "$input" == "y" ]]; then
		echo "you accepted auto start"
		echo "setting up in crontab now..."
		#define script address
		script_address="$initial_directory/directory_watch.sh"
		cron_entry="@reboot CRON=1 /home/lok-yung-chan/Project/DirectoryWatcher/directory_watch.sh /home/lok-yung-chan/Project/DirectoryWatcher/test_directory /home/lok-yung-chan/Project/DirectoryWatcher /home/lok-yung-chan/Project/DirectoryWatcher/Directory_Watcher_Log"

		#check if a watcher for this directory already registered in crontab on this device
		crontab -l 2>/dev/null | grep  -F "$cron_entry" >/dev/null

		if [ $? -ne 0 ]; then #no duplicate entry
			(crontab -l 2>/dev/null; echo "$cron_entry") | crontab -
			echo "wrote $cron_entry successfully";
		else
			echo "cron entry already exist"
		fi

	elif [[ "$input" == "n" ]]; then
		echo "skipping cron setup";
	else
		echo "invalid input, please enter y or n";
	fi
fi

#===logging logic===
/usr/bin/inotifywait -m -r -e create -e modify -e delete -e move \
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

	
