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

# The host checkout is a git worktree, so the copied .git metadata points back
# to a path that does not exist inside the container. Remove it so tests can
# validate the dotfiles contents without repo context leaking in.
RUN rm -rf .git
