# tel-net-cat scanner

### A simple bash script that can scan a target host or a list of target hosts looking for open/closed ports using netcat or telnet.

## Usage

		./tel-net-cat-scanner.sh [-t target] [-f target_file] [-p ports] [-o output_format] [-T timeout] [-s scan_tool]


## Options
		-t target: Target host or IP address to scan
		-f target_file: File containing a list of targets to scan
		-p ports: Comma-separated list of ports or a range of ports to scan (e.g. 1-3000) (default: 22)
		-o output_format: Output format: csv, xml, json (default: json)
		-T timeout: Timeout value in seconds (default: 1)
		-s scan_tool: Scan tool to use: nc, telnet (default: nc)
## Examples

### Scan a single target:

		./tel-net-cat-scanner.sh -t 192.168.0.1 -p 22,80,443


### Scan multiple targets from a file:


		./tel-net-cat-scanner.sh -f targets.txt -p 1-1024 -o xml


## Requirements

The script requires nc (Netcat) or telnet to be installed on the system.

## Output

The script outputs the results of the scan in the specified format (csv, xml, or json).

### Author

Edgar Medina
edgar.medina.m.ed@protonmail.com
