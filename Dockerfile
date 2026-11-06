FROM node:20-bookworm-slim

# apt 2.6.1 can install an unverified package from a tampered mirror, but only
# when a download is retried. So apt is upgraded to 2.6.2 or newer first, with
# retries off for the first two commands, and the build stops if the upgrade
# did not take. Each of those two commands is tried up to 3 times, always as a
# new apt process with retries still off, so one mirror hiccup does not fail
# the build. HTTPS is not possible yet: this base has no ca-certificates.
RUN set -eu; \
  try_3_times() { \
    n=1; \
    until "$@"; do \
      [ "${n}" -lt 3 ] || return 1; \
      n=$((n + 1)); \
      echo "retrying: $*" >&2; \
      sleep 5; \
    done; \
  }; \
  try_3_times apt-get -o Acquire::Retries=0 update; \
  try_3_times apt-get -o Acquire::Retries=0 install -y --only-upgrade apt; \
  for pkg in apt libapt-pkg6.0; do \
    version="$(dpkg-query -W -f='${Version}' "${pkg}")"; \
    echo "${pkg} ${version}"; \
    dpkg --compare-versions "${version}" ge 2.6.2 \
      || { echo "${pkg} ${version} is older than 2.6.2, CVE-2026-109518" >&2; exit 1; }; \
  done; \
  apt-get install -y \
    git \
    jq; \
  rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
