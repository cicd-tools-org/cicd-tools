FROM ubuntu:22.04 as sha

ARG BUILD_ARG_ARCH_FORMAT_1
ARG BUILD_ARG_ARCH_FORMAT_2
ARG BUILD_ARG_ARCH_FORMAT_3
ARG BUILD_ARG_ARCH_FORMAT_4

# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y \
       --no-install-recommends \
       ca-certificates \
       curl \
       xz-utils \
    && rm -rf /var/lib/apt/lists/*

ENV ACTIONLINT_VERSION "https://github.com/rhysd/actionlint/releases/download/v1.6.26/actionlint_1.6.26_linux_${BUILD_ARG_ARCH_FORMAT_1}.tar.gz"
ENV HADOLINT_VERSION "https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-${BUILD_ARG_ARCH_FORMAT_2}"
ENV JQ_VERSION "https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-${BUILD_ARG_ARCH_FORMAT_1}"
ENV SHFMT_VERSION "https://github.com/mvdan/sh/releases/download/v3.7.0/shfmt_v3.7.0_linux_${BUILD_ARG_ARCH_FORMAT_1}"
ENV SHELLCHECK_VERSION "https://github.com/koalaman/shellcheck/releases/download/v0.9.0/shellcheck-v0.9.0.linux.${BUILD_ARG_ARCH_FORMAT_3}.tar.xz"
ENV TOMLL_VERSION "https://github.com/pelletier/go-toml/releases/download/v2.1.1/tomll_2.1.1_linux_${BUILD_ARG_ARCH_FORMAT_1}.tar.xz"
ENV VALE_VERSION "https://github.com/errata-ai/vale/releases/download/v2.30.0/vale_2.30.0_Linux_${BUILD_ARG_ARCH_FORMAT_4}.tar.gz"
ENV VALE3_VERSION "https://github.com/errata-ai/vale/releases/download/v3.6.0/vale_3.6.0_Linux_${BUILD_ARG_ARCH_FORMAT_4}.tar.gz"

RUN mkdir -p /dist

RUN curl -sL --retry 3 "${ACTIONLINT_VERSION}" -o /tmp/actionlint.tar.gz \
    && tar xvzf /tmp/actionlint.tar.gz actionlint \
    && mv actionlint /dist

RUN curl -sL --retry 3 "${HADOLINT_VERSION}" -o /dist/hadolint \
    && chmod +x /dist/hadolint

RUN curl -sL --retry 3 "${JQ_VERSION}" -o /dist/jq \
    && chmod +x /dist/jq

RUN curl -sL --retry 3 "${SHELLCHECK_VERSION}" -o /tmp/shellcheck.tar.xz \
    && tar xvJf /tmp/shellcheck.tar.xz --strip-components=1 \
    && mv shellcheck /dist

RUN curl -sL --retry 3 "${SHFMT_VERSION}" -o /dist/shfmt \
    && chmod +x /dist/shfmt

RUN curl -sL --retry 3 "${TOMLL_VERSION}" -o /tmp/tomll.tar.xz \
    && tar xvJf /tmp/tomll.tar.xz tomll \
    && mv tomll /dist

RUN curl -sL --retry 3 "${VALE_VERSION}" -o /tmp/vale.tar.gz \
    && tar xvzf /tmp/vale.tar.gz vale \
    && mv vale /dist

RUN curl -sL --retry 3 "${VALE3_VERSION}" -o /tmp/vale3.tar.gz \
    && tar xvzf /tmp/vale3.tar.gz vale \
    && mv vale /dist/vale3

COPY ${BUILD_ARG_ARCH_FORMAT_1}/Dockerfile.sha256 /dist

WORKDIR /dist

RUN sha256sum -c Dockerfile.sha256 && exit 0 || sha256sum /dist/* && exit 127

FROM scratch as ship

LABEL org.opencontainers.image.source=https://github.com/cicd-tools-org/cicd-tools
LABEL org.opencontainers.image.description="FOSS binaries for CICD-Tools."

COPY --from=sha /dist/* /bin/
COPY --from=sha /etc/ssl/certs/* /etc/ssl/certs/
