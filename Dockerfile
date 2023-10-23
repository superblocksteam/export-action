FROM node:18-bookworm-slim

COPY entrypoint.sh /entrypoint.sh

ARG SUPERBLOCKS_CLI_VERSION='^1.1.0'

# Install Superblocks CLI dependencies
RUN apt-get update && apt-get install -y \
  git \
  jq \
  && rm -rf /var/lib/apt/lists/*

RUN npm install -g @superblocksteam/cli@"${SUPERBLOCKS_CLI_VERSION}"

ENTRYPOINT ["/entrypoint.sh"]
