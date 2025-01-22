FROM alpine:3.19 AS builder

# Build arguments with defaults
ARG CHANNEL=stable
ARG ORIGIN=local
ARG VERSION

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
    VERSION=${VERSION}

RUN /builder.sh

FROM debian:trixie-slim

COPY --from=builder --chmod=755 /build/yt-dlp_linux /usr/bin/yt-dlp

ENTRYPOINT ["/usr/bin/yt-dlp"]
