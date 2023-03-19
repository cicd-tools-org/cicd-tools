ARG ACTIONLINT_VERSION="1.6.23@sha256:02ccb6d91e4cb4a7b21eb99d5274d257e81ae667688d730e89d7ea0d6d35db91"
ARG SHFMT_VERSION="3.6.0@sha256:b68b0e33bf799f393aec27f72da64ec1d84476c8cfa9a2a7bfd0cbbdbfc8d534"
ARG SHELLCHECK_VERSION="v0.9.0@sha256:a527e2077f11f28c1c1ad1dc784b5bc966baeb3e34ef304a0ffa72699b01ad9c"
ARG TOMLL_VERSION="v2.0.7@sha256:31a4914ce328b8c7db0e7ce2ec3baf7a8f1ddb5ba430aab81754caf3ed66a2df"
ARG TRUFFLEHOG_VERSION="3.29.1@sha256:669fda964d919eb6c9b683e1cdf01ec55b17ae014ed561524f31313aafbd159c"

FROM rhysd/actionlint:${ACTIONLINT_VERSION} as actionlint
FROM mvdan/shfmt:${SHFMT_VERSION} as shfmt
FROM koalaman/shellcheck:${SHELLCHECK_VERSION} as shellcheck
FROM trufflesecurity/trufflehog:${TRUFFLEHOG_VERSION} as trufflehog
FROM ghcr.io/pelletier/go-toml:${TOMLL_VERSION} as tomll

FROM ubuntu:22.04 as jq

ENV JQ_VERSION "https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64"

# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y \
       --no-install-recommends \
       ca-certificates \
       curl \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L "${JQ_VERSION}" -o /bin/jq \
    && chmod +x /bin/jq

FROM scratch as ship

LABEL org.opencontainers.image.source=https://github.com/niall-byrne/cicd-tools
LABEL org.opencontainers.image.description="FOSS binaries for cicd-tools."

COPY --from=actionlint /usr/local/bin/actionlint /bin/actionlint
COPY --from=jq /bin/jq /bin/jq
COPY --from=shfmt /bin/shfmt /bin/shfmt
COPY --from=shellcheck /bin/shellcheck /bin/shellcheck
COPY --from=tomll /bin/tomll /bin/tomll
COPY --from=trufflehog /usr/bin/trufflehog /bin/trufflehog
