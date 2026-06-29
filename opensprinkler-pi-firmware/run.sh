#!/usr/bin/with-contenv bashio

bashio::log.info "Configuring data persistence..."

# Ensure persistent directories exist
mkdir -p /data/logs

# Clean up any corrupt/empty 0-byte files from previous configurations
for file in /data/sopts.dat /data/iopts.dat /data/prog.dat /data/nvm.dat /data/progs.dat /data/stns.dat /data/log.json /data/logs.sqlite; do
    if [ -f "$file" ] && [ ! -s "$file" ]; then
        bashio::log.warning "Removing empty/corrupt file: $file"
        rm -f "$file"
    fi
done

# Log files in /data for debugging
bashio::log.info "Files in /data before start:"
ls -la /data

# Move to the persistent volume so all files are read/written directly there
cd /data

bashio::log.info "Starting OpenSprinkler Pi firmware..."
exec /opensprinkler/OpenSprinkler