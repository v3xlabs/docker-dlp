FROM alpine:3.19 AS builder

# Build arguments with defaults
ARG CHANNEL=stable
ARG ORIGIN=local
ARG VERSION
ARG TARGETARCH

RUN apk --update add --no-cache \
    build-base \
    python3 \
    pipx \
    ;

RUN pipx install pyinstaller
# Requires above step to prepare the shared venv
RUN ~/.local/share/pipx/shared/bin/python -m pip install -U wheel
RUN apk --update add --no-cache \
    scons \
    patchelf \
    binutils \
    ;
RUN pipx install staticx

# Create build directory
RUN mkdir /build

COPY ./yt-dlp /yt-dlp
COPY --chmod=755 builder.sh /builder.sh

# Pass build arguments to the builder script
ENV CHANNEL=${CHANNEL} \
    ORIGIN=${ORIGIN} \
    VERSION=${VERSION} \
    PYTHONPATH=/yt-dlp

WORKDIR /yt-dlp

RUN /builder.sh

RUN echo "Done building" && ls -laR /yt-dlp/dist

FROM debian:trixie-slim

ARG TARGETARCH
RUN case "${TARGETARCH}" in \
    amd64) export BINARY="yt-dlp_linux" ;; \
    *) export BINARY="yt-dlp_linux_${TARGETARCH}" ;; \
    esac && \
    mkdir -p /usr/bin/ && \
    echo "Using binary: $BINARY"

COPY --from=builder --chmod=755 /yt-dlp/dist/${BINARY} /usr/bin/yt-dlp

ENTRYPOINT ["/usr/bin/yt-dlp"]
