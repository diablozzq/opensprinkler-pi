#!/usr/bin/with-contenv bashio

bashio::log.info "Configuring data persistence..."

# Ensure persistent directories exist
mkdir -p /data/logs

# Move to the persistent volume so all files are read/written directly there
cd /data

bashio::log.info "Starting OpenSprinkler Pi firmware..."
exec /opensprinkler/OpenSprinkler