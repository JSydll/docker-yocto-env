#!/bin/bash
# ------------------
# init.d/prebuilt.sh
# 
# Performs initial operations in a started dev container (such as deploying prebuilt resources).
#
# Required ENV vars:
# - PROJECT_ROOT
# - BUILD_DIR
#
# ------------------

readonly PREBUILT_SOURCES_DIR="/home/${DEV_USER}/prebuilt"

# Create the build directory if not yet existing...
mkdir -p ./build

# Check if prebuilt sources shall be deployed
echo "Checking if prebuilt sources shall be deployed to local 'build' directory..."
if [[ ! -d "${PROJECT_ROOT}/${BUILD_DIR}/downloads" ]]; then 
  echo "Deploying downloads directory..."
  mv "${PREBUILT_SOURCES_DIR}/downloads" "${PROJECT_ROOT}/${BUILD_DIR}/"
fi
if [[ ! -d "${PROJECT_ROOT}/${BUILD_DIR}/sstate-cache" ]]; then 
  echo "Deploying sstate-cache directory..."
  mv "${PREBUILT_SOURCES_DIR}/sstate-cache" "${PROJECT_ROOT}/${BUILD_DIR}/"
fi