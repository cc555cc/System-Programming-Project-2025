#!/bin/bash

#make test directory
mkdir script_test_dir

#run watcher script
./directory_watch.sh script_test_dir ScriptTestLog.json &
watcher_pid=$!
sleep 3
echo "running watcher"

#testing directory changes

# testing CREATE event
touch script_test_dir/test_file.txt
echo "created test file"

# testing MODIFY event
echo "testing test content" >> script_test_dir/test_file.txt
echo "modified test file"

# testing MOVE event
mv script_test_dir/test_file.txt script_test_dir/renamed_file.txt
echo "moved/renamed test file"

# testing DELETE event
rm script_test_dir/renamed_file.txt
echo "deleted test file"

# wait for events to be written to log file
sleep 2

#display log content
cat Directory_Watcher_Log/ScriptTestLog.json

#kills background process
kill "$watcher_pid"
