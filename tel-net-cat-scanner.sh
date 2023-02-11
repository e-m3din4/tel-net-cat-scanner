
#!/bin/bash

#Print banner
echo "______________________________________________________________________"
echo "|                                                                    |"
echo "| _|_ _ |__._  __|____ _._|_  _ _ _.._ ._  _ ._                      |"
echo "|  |_(/_|  | |(/_|_ (_(_| |_ _>(_(_|| || |(/_|                       |"
echo "|                                                                    |"
echo "|                                             Author: Edgar Medina   |"
echo "|                                    edgar.medina.m.ed@protonmail.com|"
echo "|____________________________________________________________________|"
echo ""

# Define default values
timeout=1
scan_tool="nc"
output_format="json"
ports="22"

# Helper menu to display script usage
usage() {
  echo "Usage: $(basename $0) [-t target] [-f target_file] [-p ports] [-o output_format] [-T timeout] [-s scan_tool]"
  echo "  -t target          Target host or IP address to scan"
  echo "  -f target_file     File containing a list of targets to scan"
  echo "  -p ports           Comma-separated list of ports or a range of ports to scan (e.g. 1-3000) (default: 22)"
  echo "  -o output_format   Output format: csv, xml, json (default: json)"
  echo "  -T timeout         Timeout value in seconds (default: 1)"
  echo "  -s scan_tool       Scan tool to use: nc, telnet (default: nc)"
  exit 1
}

# Parse command line arguments
while getopts "t:f:p:o:T:s:" opt; do
  case $opt in
    t) target="$OPTARG" ;;
    f) target_file="$OPTARG" ;;
    p) ports="$OPTARG" ;;
    o) output_format="$OPTARG" ;;
    T) timeout="$OPTARG" ;;
    s) scan_tool="$OPTARG" ;;
    *) usage ;;
  esac
done

# Validate required arguments
if [ -z "$target" ] && [ -z "$target_file" ]; then
  echo "ERROR: Missing required argument -t or -f"
  usage
fi

# Validate output format
if [ "$output_format" != "csv" ] && [ "$output_format" != "xml" ] && [ "$output_format" != "json" ]; then
  echo "ERROR: Invalid output format. Valid options: csv, xml, json"
  usage
fi

# Validate scan tool
if [ "$scan_tool" != "nc" ] && [ "$scan_tool" != "telnet" ]; then
  echo "ERROR: Invalid scan tool. Valid options: nc, telnet"
  usage
fi

# Convert port range to a list of ports
if [[ "$ports" =~ ^[0-9]+-[0-9]+$ ]]; then
  IFS=- read start end <<< "$ports"
  ports=""
  for port in $(seq $start $end); do
    ports="$ports,$port"
  done
  ports="${ports:1}"
fi

# Function to scan a target
scan_target() {
  local target=$1
  local ports=$2

  for port in $(echo "$ports" | tr "," " "); do
    if [ "$scan_tool" == "nc" ]; then
      result=$(nc -z -w "$timeout" "$target" "$port" 2>/dev/null && echo "open" || echo "closed")
    elif [ "$scan_tool" == "telnet" ]; then
      result=$(timeout "$timeout" telnet "$target" "$port" 2>/dev/null | grep -q "Connected" && echo "open" || echo "closed")
    fi

    if [ "$output_format" == "csv" ]; then
      echo "$target,$port,$result"
    elif [ "$output_format" == "xml" ]; then
      echo "<target><host>$target</host><port>$port</port><status>$result</status></target>"
    elif [ "$output_format" == "json" ]; then
      echo "{\"host\":\"$target\", \"port\":\"$port\", \"status\":\"$result\"}"
    fi

    printf "Scanning $target on port $port\r" # display progress on the same line
  done
}

# Scan targets
if [ -n "$target" ]; then
  scan_target "$target" "$ports"
elif [ -n "$target_file" ]; then
  while read -r target; do
    scan_target "$target" "$ports"
  done < "$target_file"
fi

echo # Move cursor to the next line after scanning is complete
printf 'Scanning complete'
