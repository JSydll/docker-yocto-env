#!/bin/bash -e
# ------------------
# init.d/bitbake.sh
# 
# Initializes the bitbake build environment.
#
# Required ENV vars:
# - PROJECT_ROOT
# - POKY_DIR
# - BUILD_DIR
# - PROJECT_TEMPLATE_DIR
#
# ------------------

# Delete local.conf to force template usage
if [[ -e "${PROJECT_ROOT}/${BUILD_DIR}/conf/local.conf" ]]; then
  echo "Removing existing local.conf to be sure to get latest templates..."
  rm -rf "${PROJECT_ROOT}/${BUILD_DIR}/conf"
fi

# Note: Extra env vars can be exported to the bitbake environment by adding them to BB_ENV_PASSTHROUGH_ADDITIONS

# Set template conf directory
export TEMPLATECONF="${PROJECT_ROOT}/${PROJECT_TEMPLATE_DIR}"
# shellcheck disable=SC1090
. "${PROJECT_ROOT}/${POKY_DIR}/oe-init-build-env" &> /dev/null
