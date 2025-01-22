#!/bin/ash
set -e

# Default values for build parameters
: "${CHANNEL:=stable}"
: "${ORIGIN:=local}"
: "${VERSION:=$(date +%Y.%m.%d)}"

source ~/.local/share/pipx/venvs/pyinstaller/bin/activate
python -m yt_dlp.devscripts.install_deps --include secretstorage --include curl-cffi
python -m yt_dlp.devscripts.make_lazy_extractors
python devscripts/update-version.py -c "${CHANNEL}" -r "${ORIGIN}" "${VERSION}"
python -m yt_dlp.bundle.pyinstaller --onedir
deactivate

source ~/.local/share/pipx/venvs/staticx/bin/activate
staticx /yt-dlp/dist/yt-dlp_linux /build/yt-dlp_linux
deactivate
