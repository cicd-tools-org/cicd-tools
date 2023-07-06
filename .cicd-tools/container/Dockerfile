ARG ACTIONLINT_VERSION="1.6.23@sha256:02ccb6d91e4cb4a7b21eb99d5274d257e81ae667688d730e89d7ea0d6d35db91"
ARG SHFMT_VERSION="3.6.0@sha256:b68b0e33bf799f393aec27f72da64ec1d84476c8cfa9a2a7bfd0cbbdbfc8d534"
ARG SHELLCHECK_VERSION="v0.9.0@sha256:a527e2077f11f28c1c1ad1dc784b5bc966baeb3e34ef304a0ffa72699b01ad9c"
ARG TOMLL_VERSION="v2.0.7@sha256:31a4914ce328b8c7db0e7ce2ec3baf7a8f1ddb5ba430aab81754caf3ed66a2df"
ARG VALE_VERSION="v2.27.0@sha256:f5ef07ddd8627e261be31983e2bddcdf5596dc8ca8dac19c3b51655657f712dd"

FROM rhysd/actionlint:${ACTIONLINT_VERSION} as actionlint
FROM mvdan/shfmt:${SHFMT_VERSION} as shfmt
FROM koalaman/shellcheck:${SHELLCHECK_VERSION} as shellcheck
FROM ghcr.io/pelletier/go-toml:${TOMLL_VERSION} as tomll
FROM jdkato/vale:${VALE_VERSION} as vale

FROM ubuntu:22.04 as sha

ENV JQ_VERSION "https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64"
ENV JQ_SHA "af986793a515d500ab2d35f8d2aecd656e764504b789b66d7e1a0b727a124c44"

# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y \
       --no-install-recommends \
       ca-certificates \
       curl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /dist

RUN curl -sL --retry 3 "${JQ_VERSION}" -o /dist/jq \
    && chmod +x /dist/jq

COPY --from=actionlint /usr/local/bin/actionlint /dist
COPY --from=shfmt /bin/shfmt /dist
COPY --from=shellcheck /bin/shellcheck /dist
COPY --from=tomll /bin/tomll /dist
COPY --from=vale /bin/vale /dist

COPY Dockerfile.sha256 /dist

WORKDIR /dist

RUN sha256sum -c Dockerfile.sha256

FROM scratch as ship

LABEL org.opencontainers.image.source=https://github.com/cicd-tools-org/cicd-tools
LABEL org.opencontainers.image.description="FOSS binaries for CICD-Tools."

COPY --from=sha /dist/* /bin/
