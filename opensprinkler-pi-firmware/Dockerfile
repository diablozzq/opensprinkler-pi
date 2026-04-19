ARG BUILD_FROM
FROM $BUILD_FROM

# Install dependencies matching the official OSPi install docs
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    libi2c-dev \
    libgpiod-dev \
    && rm -rf /var/lib/apt/lists/*

# Clone official firmware with submodules, exactly as the official docs
RUN git clone --recurse-submodules \
    https://github.com/OpenSprinkler/OpenSprinkler-Firmware.git \
    /opensprinkler

WORKDIR /opensprinkler

# Build for OSPi using the official build script
# 'echo n' skips the interactive prompt about setting up a systemd startup service
RUN echo "n" | bash build.sh ospi

# Copy and permission the run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]