FROM debian:trixie-slim AS builder

# Build arguments with defaults
ARG CHANNEL=stable
ARG ORIGIN=local
ARG VERSION
ARG TARGETARCH

RUN apt-get update && apt-get install -y \
    build-essential \
    python3 \
    python3-pip \
    python3-venv \
    pipx \
    scons \
    patchelf \
    binutils \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="/root/.local/bin:${PATH}"

RUN pipx install pyinstaller
# Requires above step to prepare the shared venv
RUN ~/.local/share/pipx/shared/bin/python -m pip install -U wheel
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

RUN bash /builder.sh

RUN echo "Done building" && ls -laR /yt-dlp/dist

FROM debian:trixie-slim

ARG TARGETARCH
COPY --from=builder --chmod=755 /yt-dlp/dist/yt-dlp_linux* /yt-dlp

RUN ln -s $(find /yt-dlp -name "yt-dlp_linux*" | head -n 1) /usr/bin/yt-dlp

ENTRYPOINT ["/usr/bin/yt-dlp"]
