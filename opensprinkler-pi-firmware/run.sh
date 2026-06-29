#!/usr/bin/with-contenv bashio

bashio::log.info "Configuring data persistence..."

mkdir -p /data/logs

# Correct filenames per defines.h in the actual firmware source:
# nvcon.dat = non-volatile controller data (NOT nvm.dat)
# prog.dat  = program data
# done.dat  = signals completion of file init
# sopts.dat = string options
# iopts.dat = integer options
# stns.dat  = station data
# log.json  = log file
DATA_FILES="nvcon.dat prog.dat done.dat sopts.dat iopts.dat stns.dat log.json"

for file in $DATA_FILES; do
    src="/opensprinkler/${file}"
    dst="/data/${file}"

    if [ -f "$src" ] && [ ! -L "$src" ] && [ ! -f "$dst" ]; then
        bashio::log.info "First run: seeding ${file} into /data"
        cp "$src" "$dst"
    fi

    rm -f "$src"
    ln -sf "$dst" "$src"
done

rm -rf /opensprinkler/logs
ln -sf /data/logs /opensprinkler/logs

bashio::log.info "=== Symlink verification ==="
for file in $DATA_FILES; do
    if [ -L "/opensprinkler/${file}" ]; then
        target=$(readlink "/opensprinkler/${file}")
        size=$([ -f "$target" ] && stat -c%s "$target" || echo "MISSING")
        bashio::log.info "OK: /opensprinkler/${file} -> ${target} (${size} bytes)"
    else
        bashio::log.warning "MISSING SYMLINK: /opensprinkler/${file}"
    fi
done

bashio::log.info "=== Files in /data ==="
ls -la /data/

bashio::log.info "Starting OpenSprinkler Pi firmware..."
exec /opensprinkler/OpenSprinkler