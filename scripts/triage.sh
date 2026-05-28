#!/bin/bash

LOG_FILE="../data/app.log"
DB_FILE="../data/db.sqlite"
WEBHOOK_URL=""

echo "Analyzing logs for errors..."

if grep -q "ERROR" "$LOG_FILE"; then
	echo "[Alert] Found errors in the logs! Processing..."

	grep "ERROR" "$LOG_FILE" | while read -r ERROR_LINE; do

		TXN_ID=$(echo ${ERROR_LINE} | grep -o "TXN-[0-9]*")
		ERROR_TIME=$(echo ${ERROR_LINE} | awk '{print $1, $2}' | tr -d '[]')

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

				echo "	 Gathering system metrics..."
				RAM_FREE=$(free -m | awk '/Mem:/ {print $4}')
				CPU_LOAD=$(uptime | awk -F 'load average:' '{ print $2 }' | xargs)

				echo "		Free RAM: ${RAM_FREE}MB"
				echo "		CPU LOAD: ${CPU_LOAD}"

				PAYLOAD=$(cat <<EOF
{
	"content": "## CRITICAL ERROR DETECTED!\n**Time of Error:** $ERROR_TIME\n**Transaction ID:** $TXN_ID\n**Customer ID:** $CUST_ID\n**Service:** $SERVICE\n**Status in DB:** $STATUS\n\n**Server Status:**\n Free RAM: ${RAM_FREE}MB\n CPU Load: ${CPU_LOAD}"
}
EOF
)
				
				if [ -n "$WEBHOOK_URL" ]; then
					echo "	Sending alert to Discord..."
					curl -s -H "Content-Type: application/json" -d "$PAYLOAD" "$WEBHOOK_URL" > /dev/null
					echo "	[OK] Alert sent!"
				else
					echo "	[i] Discord Webhool URL not configured. Skipping alert."
				fi
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
