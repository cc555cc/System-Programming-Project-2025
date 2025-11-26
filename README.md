# Directory Watcher

## Prerequisites

- Linux
- `inotify-tools` and `dos2unix`
- Bash shell

### Installing Prerequisites

```bash
sudo apt-get update
sudo apt-get install inotify-tools dos2unix
```

## Usage

### Basic Usage

```bash
./directory_watch.sh <directory_to_watch> [log_file_name]
```

**Parameters:**
- `<directory_to_watch>` - Directory to path you want to monitor (required)
- `[log_file_name]` - JSON log file name (optional, defaults to `<directory_name>_change_log.json` if not specified)

**Example:**
```bash
./directory_watch.sh ~/Downloads MyLogFile.json
```

This will:
- Monitor the `~/Downloads` directory
- Create a log directory: `Directory_Watcher_Log/`
- Save events to: `Directory_Watcher_Log/MyLogFile.json`

### Stopping the Watcher

Press `Ctrl+C` to stop monitoring.

## Testing Instructions (included test.sh)

1. **Navigate to the project directory:**
   ```bash
   cd whatever_path/System-Programming-Project-2025
   ```

2. **Convert scripts to Unix style:**
   ```bash
   dos2unix directory_watch.sh test.sh
   ```

3. **Give Execution Permissions:**
   ```bash
   chmod +x directory_watch.sh test.sh
   ```

4. **Run test script:**
   ```bash
   ./test.sh
   ```

The test script will:
- Creates test directory (`script_test_dir`)
- Starts the directory watcher
- Performs the needed file operations (create, modify, move, delete)
- Displays the events logged
- Kills the watcher process

## Cleanup (optional)

removes test directories made

```bash
rm -rf script_test_dir
rm -rf Directory_Watcher_Log
```
