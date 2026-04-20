#!/usr/bin/with-contenv bashio

bashio::log.info "Configuring data persistence..."

cd /opensprinkler

# Persist config and log files
for file in nvm.dat progs.dat stns.dat log.json logs.sqlite; do
    if [ ! -f "/data/$file" ]; then
        # Initialize if it doesn't exist in /data
        touch "/data/$file"
    fi
    # Link it back to the OpenSprinkler directory
    ln -sf "/data/$file" "/opensprinkler/$file"
done

bashio::log.info "Starting OpenSprinkler Pi firmware..."
exec ./OpenSprinkler