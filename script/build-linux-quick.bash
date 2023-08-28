#!/usr/bin/env bash

##
## Global config
##
DIRNAME_CLI=/usr/bin/dirname
PWD_CLI=/usr/bin/pwd

echo "[Linux] Running quick (re)build ..."
MY_PROJECT_SHOULD_DISABLE_CLEAN_BUILD=ON

SCRIPT_DIR=$(cd -- "$(${DIRNAME_CLI} -- "${BASH_SOURCE[0]}")" &> /dev/null && ${PWD_CLI})
source $SCRIPT_DIR/build-linux-preset.bash
