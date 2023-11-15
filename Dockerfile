FROM node:18-bookworm-slim

ARG SUPERBLOCKS_CLI_VERSION='^1.3.0'

# Install Superblocks CLI dependencies
RUN apt-get update && apt-get install -y \
  git \
  jq \
  && rm -rf /var/lib/apt/lists/*

RUN npm install -g @superblocksteam/cli@"${SUPERBLOCKS_CLI_VERSION}"

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
