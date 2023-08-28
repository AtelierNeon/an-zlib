#!/usr/bin/env bash

##
## Global config
##
DIRNAME_CLI=/usr/bin/dirname
PWD_CLI=/usr/bin/pwd

echo "[Linux] Applying preset options ..."
MY_PROJECT_ZLIB_WITH_DISABLED_TEST_APPS=ON
echo "[Linux] Applying default options ... DONE"

SCRIPT_DIR=$(cd -- "$(${DIRNAME_CLI} -- "${BASH_SOURCE[0]}")" &> /dev/null && ${PWD_CLI})
source $SCRIPT_DIR/build-linux.bash
