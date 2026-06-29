#!/usr/bin/with-contenv bashio

bashio::log.info "Configuring data persistence..."

# Ensure persistent directories exist
mkdir -p /data/logs

# These are the files OpenSprinkler writes next to its own binary
# get_runtime_path() uses /proc/self/exe, so it always writes to /opensprinkler/
DATA_FILES="sopts.dat iopts.dat prog.dat nvm.dat progs.dat stns.dat log.json"

for file in $DATA_FILES; do
    src="/opensprinkler/${file}"
    dst="/data/${file}"

    # If a real (non-symlink) file exists at src but not in /data, seed /data with it
    if [ -f "$src" ] && [ ! -L "$src" ] && [ ! -f "$dst" ]; then
        bashio::log.info "First run: seeding ${file} from image into /data"
        cp "$src" "$dst"
    fi

    # Remove whatever is at src (real file, stale symlink, or nothing) and create fresh symlink
    rm -f "$src"
    ln -sf "$dst" "$src"
done

# Handle the logs directory
rm -rf /opensprinkler/logs
ln -sf /data/logs /opensprinkler/logs

# Clean up any empty/zero-byte files in /data AFTER symlinking
# (empty files cause firmware to factory-reset on next start)
for file in $DATA_FILES; do
    dst="/data/${file}"
    if [ -f "$dst" ] && [ ! -s "$dst" ]; then
        bashio::log.warning "Removing empty/corrupt file: ${dst}"
        rm -f "$dst"
    fi
done

# Diagnostic output so you can verify in HA logs
bashio::log.info "=== Symlink verification ==="
for file in $DATA_FILES; do
    if [ -L "/opensprinkler/${file}" ]; then
        bashio::log.info "OK: /opensprinkler/${file} -> $(readlink /opensprinkler/${file})"
    else
        bashio::log.warning "MISSING SYMLINK: /opensprinkler/${file}"
    fi
done

bashio::log.info "=== Files in /data ==="
ls -la /data/
ls -la /data/logs/ 2>/dev/null || true

bashio::log.info "Starting OpenSprinkler Pi firmware..."
exec /opensprinkler/OpenSprinkler