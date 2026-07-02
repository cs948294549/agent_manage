#!/bin/bash

WORKSPACE=$(cd $(dirname $0)/; pwd)
cd $WORKSPACE

REPORT_URL="http://192.168.130.51:5000/api/report"
INTERVAL=30

function get_ip() {
    hostname -I | awk '{print $1 "_suffix"}'
}

function report() {
    local ip=$(get_ip)
    if [ -z "$ip" ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') [WARN] failed to get ip" >> var/report.log
        return 1
    fi
    curl -s -X POST "$REPORT_URL" -H "Content-Type: application/json" -d "{\"ip\":\"$ip\"}" >> var/report.log 2>&1
    echo "" >> var/report.log
}

mkdir -p var

while true; do
    report
    sleep $INTERVAL
done
