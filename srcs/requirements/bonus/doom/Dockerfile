## ************************************************************************** //
##                              Doom Dockerfile                               //
## ************************************************************************** //

FROM debian:bullseye

# Install Dependencies
RUN apt-get update && apt upgrade -y && \
  apt-get install -y git gcc g++ clang curl wget xz-utils cmake make \
  lsb-release software-properties-common gnupg ca-certificates netcat && \
  rm -rf /var/lib/apt/lists/*

# Install Zig
ARG ZIG_VERSION=0.12.0
RUN wget https://ziglang.org/download/${ZIG_VERSION}/zig-linux-x86_64-${ZIG_VERSION}.tar.xz \
    && tar -xf zig-linux-x86_64-${ZIG_VERSION}.tar.xz \
    && mv zig-linux-x86_64-${ZIG_VERSION} /usr/local/zig \
    && ln -s /usr/local/zig/zig /usr/local/bin/zig \
    && rm zig-linux-x86_64-${ZIG_VERSION}.tar.xz


# Get Doom
RUN git clone https://github.com/cryptocode/terminal-doom.git /terminal-doom

# Build Doom
WORKDIR /terminal-doom
RUN zig build -Doptimize=ReleaseFast

# Expose Doom ports
# EXPOSE 3333

# Copy custom Entrypoint bash script
COPY ./tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && \
    # Ensure CRLF issues are resolved
    sed -i 's/\r$//' /entrypoint.sh
  
# Set entrypoint
ENTRYPOINT [ "/entrypoint.sh" ]

