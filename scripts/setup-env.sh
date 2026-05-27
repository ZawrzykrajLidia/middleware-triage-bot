#!/bin/bash

# File paths

LOG_FILE="../data/app.log"
DB_FILE="../data/db.sqlite"

echo "Creating the mock environment..."

echo "Setting up SQLite database..."

sqlite3 $DB_FILE "CREATE TABLE IF NOT EXISTS transactions (transaction_id TEXT PRIMARY KEY, customer_id TEXT, service_type TEXT, status TEXT);"
sqlite3 $DB_FILE "DELETE FROM transactions"

SERVICES=("Mobile-Activation" "Broadband-Billing" "Fiber-Upgrade" "IPTV-Setup")
STATUSES=("SUCCESS" "PENDING" "FAILED" "TIMEOUT")

echo "Generating random transaction..."
echo "Begin transaction" > temp_insert.sql

for i in {1..50}; do
	TXN_ID="TXN-$((1000 + RANDOM % 90000))"
	CUST_ID="CUST-$((100 + RANDOM % 900))"

	SERVICE=${SERVICES[$RANDOM % 4]}
	STATUS=${STATUSES[$RANDOM % 4]}

	echo "INSERT INTO transactions (transaction_id, customer_id, service_type, status) VALUES ('$TXN_ID', '$CUST_ID', '$SERVICE', '$STATUS');" >> temp_insert.sql
done

echo "INSERT INTO transactions (transaction_id, customer_id, service_type, status) VALUES ('TXN-88192', 'CUST-001', 'Mobile-Activation', 'Failed');" >> temp_insert.sql

echo "COMMIT;" >> temp_insert.sql

rm temp_insert.sql

echo "Generating sample application logs..." > $LOG_FILE

LEVELS=("INFO" "DEBUG" "WARN")
WORKERS=("Worker-1" "Worker-2" "Worker-3" "Worker-4")
MESSAGES=("Processing standard payload..." "Service heartbeat OK." "Cleaning up temp files." "Message routed successfully." " Connection pool metric updated." "Validating XML Schema.")

for i in {1..40}; do
	TIMESTAMP="2026-05-20 10:$((15 + i / 60)):$(printf "%02d" $((i % 60)))"

	# Inject the ERROR in the middle
	if [ $i -eq 20 ]; then
		echo "[$TIMESTAMP] ERROR [Worker-3] TimeoutException: Connection to core database timed out . TransactionID=TXN-88192" >> $LOG_FILE
	else
		LEVEL=${LEVELS[$RANDOM % 3]}
		WORKER=${WORKERS[$RANDOM % 4]}
		MSG=${MESSAGES[$RANDOM % 6]}

		if [ "$LEVEL" == "INFO" ] || [ "$LEVEL" == "WARN" ]; then
			LEVEL="$LEVEL "
		fi

		echo "[$TIMESTAMP] $LEVEL [$WORKER] $MSG" >> $LOG_FILE
	fi
done

echo "Environment setup complete. Generated 51 DB records and 40 log lines"
