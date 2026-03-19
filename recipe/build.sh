#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Patch package.json to skip unneeded prepare step
mv package.json package.json.bak
jq 'del(.packageManager)' package.json.bak > package.json

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --no-bin-links \
    --global \
    --build-from-source \
    ${SRC_DIR}/${PKG_NAME}-${PKG_VERSION}.tgz

# Create license report for dependencies
pnpm install
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

mkdir ${PREFIX}/bin
tee ${PREFIX}/bin/hereby << EOF
exec \${CONDA_PREFIX}/lib/node_modules/hereby/bin/hereby.js "\$@"
EOF
chmod +x ${PREFIX}/bin/hereby

tee ${PREFIX}/bin/hereby.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\lib\node_modules\hereby\bin\hereby.js %*
EOF
