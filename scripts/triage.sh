#!/bin/bash

LOG_FILE="../data/app.log"
DB_FILE="../data/db.sqlite"

echo "Analyzing logs for errors..."

if grep -q "ERROR" "$LOG_FILE"; then
	echo "[Alert] Found errors in the logs! Processing..."

	grep "ERROR" "$LOG_FILE" | while read -r ERROR_LINE; do

		TXN_ID=$(echo ${ERROR_LINE} | grep -o "TXN-[0-9]*")

		if [ -n "$TXN_ID" ]; then
			echo "-> Extracted Transaction ID: $TXN_ID"
			echo "	 Querying the database for transaction details..."

			DB_RESULT=$(sqlite3 "$DB_FILE" "SELECT customer_id, service_type, status FROM transactions WHERE transaction_id='$TXN_ID';")

			if [ -n "$DB_RESULT" ]; then
				CUST_ID=$(echo ${DB_RESULT} | cut -d "|" -f 1)
				SERVICE=$(echo ${DB_RESULT} | cut -d "|" -f 2)
				STATUS=$(echo ${DB_RESULT} | cut -d "|" -f 3)
				echo "	 [!] TICKET DETAILS:"
				echo "		Customer ID: $CUST_ID"
				echo "		Service: $SERVICE"
				echo "		DB Status: $STATUS"
			else
				echo "	 [!] WARNING: Transaction ID $TXN_ID not found in the databse!"
			fi

		else
			echo "-> Found an ERROR line, but no Transaction ID attached."
			echo "	 Log content: $ERROR_LINE"
		fi
	done
else
	echo "[OK] No errors found."
fi
