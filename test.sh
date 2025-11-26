#!/bin/bash

#make test directory
mkdir script_test_dir

#run watcher script
./directory_watch.sh script_test_dir ScriptTestLog.json &
watcher_pid=$!
sleep 3
echo "running watcher"

#test directory changes
touch script_test_dir/test_file.txt
echo "testing" >> script_test_dir/test_file.txt test content
echo "finished adding test file"

#display log content
cat Directory_Watcher_Log/ScriptTestLog.json

#error handling test
./directory_watch.sh script_test_dir_2 ScriptTestLog2.json
