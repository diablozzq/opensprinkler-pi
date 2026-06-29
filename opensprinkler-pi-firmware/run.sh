#!/usr/bin/with-contenv bashio

bashio::log.info "Configuring data persistence..."

# Ensure persistent directories exist
mkdir -p /data/logs

# List of files the OpenSprinkler firmware reads/writes next to its binary
DATA_FILES="sopts.dat iopts.dat prog.dat nvm.dat progs.dat stns.dat log.json"

for file in $DATA_FILES; do
    src="/opensprinkler/${file}"
    dst="/data/${file}"

    # If there's already a real file at the src location (not a symlink),
    # and no file in /data yet, seed /data with it (first boot)
    if [ -f "$src" ] && [ ! -L "$src" ] && [ ! -f "$dst" ]; then
        bashio::log.info "Seeding $file into /data (first run)"
        cp "$src" "$dst"
    fi

    # Remove whatever is at src (real file or broken symlink) and replace with symlink
    rm -f "$src"
    ln -sf "$dst" "$src"
    bashio::log.info "Linked: $src -> $dst"
done

# Also handle the logs directory
if [ ! -L "/opensprinkler/logs" ]; then
    rm -rf "/opensprinkler/logs"
    ln -sf /data/logs /opensprinkler/logs
    bashio::log.info "Linked: /opensprinkler/logs -> /data/logs"
fi

# Clean up any empty/zero-byte files in /data that would cause the firmware
# to treat them as corrupt and factory-reset (do this AFTER symlinking)
for file in $DATA_FILES; do
    dst="/data/${file}"
    if [ -f "$dst" ] && [ ! -s "$dst" ]; then
        bashio::log.warning "Removing empty/corrupt file in /data: $dst"
        rm -f "$dst"
    fi
done

bashio::log.info "Files in /data before start:"
ls -la /data

bashio::log.info "Symlinks in /opensprinkler before start:"
ls -la /opensprinkler/*.dat /opensprinkler/*.json 2>/dev/null || true

bashio::log.info "Starting OpenSprinkler Pi firmware..."
exec /opensprinkler/OpenSprinkler