# Middleware Triage Bot

A bash-automation tool designed to simulate an A Bash-based automation tool designed to simulate an L1/L2 Support environment. It actively scans application logs for errors, enriches the findings by querying a relational database, gathers current system metrics, and dispatches actionable, formatted alerts via webhooks.

## Repository Structure

```text
middleware-triage-bot/
├── config/
│   └── settings.conf.example   # Configuration template
├── data/                       # Directory for mock logs and DB
├── scripts/
│   ├── setup_env.sh            # Generates mock DB records and application logs
│   └── triage.sh               # Main automated triage script
├── .gitignore
└── README.md
```

## Quick Start

1. Clone the repository and navigate to the project directory:

```bash
git clone https://github.com/ZawrzykrajLidia/middleware-triage-bot.git

cd middleware-triage-bot
```

2. Configure the environment:
Create your local configuration file from the provided template.

```bash
cp config/settings.conf.example config/settings.conf
```

3. Generate mock data:
Run the setup script to create a fresh SQLite database with random transactions and generate a sample log file containing simulated errors.

```bash
cd scripts
chmod +x setup_env.sh triage.sh
./setup_env.sh
```

4. Run the Triage Bot:
Execute the main script to analyze the logs, query the DB, and send an alert.

```bash
./triage.sh
```