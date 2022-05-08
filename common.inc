readonly RELEASE_TAG="$(git rev-parse --abbrev-ref HEAD)"

# Using a fixed version to avoid upstream changes to create conflicts with the working setup
readonly DOCKER_BASE_FROM="ubuntu:focal-20220426"
readonly DOCKER_BASE_IMAGE_NAME="yocto-base-env"
readonly DOCKER_PREBUILT_IMAGE_NAME="yocto-prebuilt-env"

readonly BASE_IMAGE_TAR="docker.${DOCKER_BASE_IMAGE_NAME}.tar.gz"
readonly PREBUILT_IMAGE_TAR="docker.${DOCKER_PREBUILT_IMAGE_NAME}.tar.gz"

readonly BITBAKE_INIT_ENV="~/init.d/bitbake.sh"