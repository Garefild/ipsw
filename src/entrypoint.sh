#!/bin/bash
set -e

# Replace placeholders in config.yml with environment variables
envsubst < /config/config.yml > /config/config_generated.yml

# Start ipswd with the generated config
exec ipswd start -c /config/config_generated.yml
