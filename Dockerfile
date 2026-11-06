FROM node:20-bookworm-slim

# apt 2.6.1 can install an unverified package from a tampered mirror, but only
# when a download is retried. So apt is upgraded to 2.6.2 or newer first, with
# retries off for the first two commands, and the build stops if the upgrade
# did not take. HTTPS is not possible yet: this base has no ca-certificates.
RUN apt-get -o Acquire::Retries=0 update \
  && apt-get -o Acquire::Retries=0 install -y --only-upgrade apt \
  && apt_version="$(dpkg-query -W -f='${Version}' apt)" \
  && lib_version="$(dpkg-query -W -f='${Version}' libapt-pkg6.0)" \
  && echo "apt ${apt_version} libapt-pkg6.0 ${lib_version}" \
  && dpkg --compare-versions "${apt_version}" ge 2.6.2 \
  && dpkg --compare-versions "${lib_version}" ge 2.6.2 \
  && apt-get install -y \
    git \
    jq \
  && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
