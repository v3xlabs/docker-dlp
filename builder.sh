#!/bin/ash
set -e

# Default values for build parameters
: "${CHANNEL:=stable}"
: "${ORIGIN:=local}"
: "${VERSION:=$(date +%Y.%m.%d)}"

source ~/.local/share/pipx/venvs/pyinstaller/bin/activate
python -m devscripts.install_deps --include secretstorage --include curl-cffi
python -m devscripts.make_lazy_extractors
python devscripts/update-version.py -c "${CHANNEL}" -r "${ORIGIN}" "${VERSION}"
python -m bundle.pyinstaller --onedir
deactivate
