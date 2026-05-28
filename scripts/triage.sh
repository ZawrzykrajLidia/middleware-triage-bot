#!/bin/bash

LOG_FILE="../data/app.log"

echo "Analyzing logs for errors..."

if grep -q "ERROR" "$LOG_FILE"; then
	echo "Found errors in the logs! Processing..."

	grep "ERROR" "$LOG_FILE" | while read -r ERROR_LINE; do

		TXN_ID=$(echo ${ERROR_LINE} | grep -o "TXN-[0-9]*")

		if [ -n "$TXN_ID" ]; then
			echo "-> Extracted Transaction ID: $TXN_ID"

		else
			echo "-> Found an ERROR line, but no Transaction ID attached."
			echo "	 Log content: $ERROR_LINE"
		fi
	done
else
	echo "[OK] No errors found."
fi
