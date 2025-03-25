FROM node:20-bookworm-slim

# Install Superblocks CLI dependencies
RUN apt-get update && apt-get install -y \
  git \
  jq \
  && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
