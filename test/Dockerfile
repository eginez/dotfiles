FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Minimal bootstrap only — install.sh is responsible for the rest
RUN apt-get update -qq && apt-get install -y \
    sudo \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Non-root user that mirrors a real workstation setup
RUN useradd -m -s /bin/bash testuser \
    && echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER testuser
WORKDIR /home/testuser/dotfiles

# Copy dotfiles repo in (owned by testuser)
COPY --chown=testuser:testuser . .
