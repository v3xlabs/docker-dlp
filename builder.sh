#!/bin/ash
set -e

# Default values for build parameters
: "${CHANNEL:=stable}"
: "${ORIGIN:=local}"
: "${VERSION:=$(python -c "import yt_dlp; print(yt_dlp.__version__)")}"

echo "Building with version: ${VERSION}"

source ~/.local/share/pipx/venvs/pyinstaller/bin/activate
python3 -m devscripts.install_deps --include secretstorage --include curl-cffi
python3 -m devscripts.make_lazy_extractors
python3 devscripts/update-version.py -c "${CHANNEL}" -r "${ORIGIN}" "${VERSION}"
python3 -m bundle.pyinstaller --onedir
deactivate
