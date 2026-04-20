ARG BUILD_FROM
FROM $BUILD_FROM

# Install dependencies matching the official OSPi install docs, plus lgpio build reqs
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    libi2c-dev \
    libgpiod-dev \
    libmosquitto-dev \
    libssl-dev \
    swig \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Build lgpio from source (required for newer OpenSprinkler firmware)
RUN git clone https://github.com/joan2937/lg && \
    cd lg && \
    make && \
    make install && \
    cd .. && \
    rm -rf lg

# Clone official firmware with submodules, exactly as the official docs
RUN git clone --recurse-submodules \
    https://github.com/OpenSprinkler/OpenSprinkler-Firmware.git \
    /opensprinkler

WORKDIR /opensprinkler

# Remove liblgpio-dev from build.sh since we compiled it from source
RUN sed -i 's/liblgpio-dev//g' build.sh

# Build for OSPi using the official build script
# 'echo n' skips the interactive prompt about setting up a systemd startup service
RUN echo "n" | bash build.sh ospi

# Copy and permission the run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]