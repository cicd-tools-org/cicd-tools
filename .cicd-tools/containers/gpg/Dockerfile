FROM debian:stable

LABEL org.opencontainers.image.source=https://github.com/cicd-tools-org/cicd-tools
LABEL org.opencontainers.image.description="FOSS gnupg binaries for CICD-Tools."

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install \
      -y \
      --no-install-recommends \
      gnupg2=2.4.* && \
    apt-get clean && \
    rm -rf /var/cache/apt/* && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

RUN mkdir -p /mnt
WORKDIR /mnt
