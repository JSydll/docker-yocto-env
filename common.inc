#!/bin/bash
# shellcheck disable=SC2034
RELEASE_TAG="${RELEASE_TAG:-$(git rev-parse --abbrev-ref HEAD)}"
readonly RELEASE_TAG

# Using a fixed version to avoid upstream changes to create conflicts with the working setup
# shellcheck disable=SC2034
readonly DOCKER_BASE_FROM="ubuntu:focal-20220426"
# shellcheck disable=SC2034
readonly DOCKER_BASE_IMAGE_NAME="yocto-base-env"
# shellcheck disable=SC2034
readonly DOCKER_PREBUILT_IMAGE_NAME="yocto-prebuilt-env"

# shellcheck disable=SC2034
readonly BASE_IMAGE_TAR="docker.${DOCKER_BASE_IMAGE_NAME}.tar.gz"
# shellcheck disable=SC2034
readonly PREBUILT_IMAGE_TAR="docker.${DOCKER_PREBUILT_IMAGE_NAME}.tar.gz"

# shellcheck disable=SC2034
readonly BITBAKE_INIT_ENV="${HOME}/init.d/bitbake.sh"