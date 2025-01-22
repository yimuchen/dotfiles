#!/bin/sh
echo "RCB_PORT=$(shuf -i 9500-9600 -n 1)"
echo "RCB_TOKEN=rcb-token-$(od -vN '16' -An -tx1 /dev/urandom | tr -d ' \n')"
