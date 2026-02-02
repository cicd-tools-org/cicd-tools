FROM debian:trixie

LABEL org.opencontainers.image.source=https://github.com/cicd-tools-org/cicd-tools
LABEL org.opencontainers.image.description="FOSS gettext binaries for CICD-Tools."

ENV DEBIAN_FRONTEND=noninteractive

RUN echo "deb http://security.debian.org trixie-security main contrib non-free" >> /etc/apt/sources.list.d/security.list && \
    echo "deb-src http://security.debian.org trixie-security main contrib non-free" >> /etc/apt/sources.list.d/security.list
COPY __shared__/security.pref /etc/apt/preferences.d/security.pref

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install \
      -y \
      --no-install-recommends \
      gettext=0.* && \
    apt-get clean && \
    rm -rf /var/cache/apt/* && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

RUN mkdir -p /mnt
WORKDIR /mnt
