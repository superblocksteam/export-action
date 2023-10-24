FROM node:18-bookworm-slim

COPY entrypoint.sh /entrypoint.sh

# Install Superblocks CLI dependencies
RUN apt-get update && apt-get install -y \
  git \
  jq \
  && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/entrypoint.sh"]
