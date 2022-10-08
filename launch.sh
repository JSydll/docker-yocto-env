#!/bin/bash -e
# ------------------
# launch.sh
# 
# Launches a new background container for the given image.
#
# ------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)"
readonly SCRIPT_DIR
. "${SCRIPT_DIR}/common.inc"

function print_help()
{
  cat <<EOF 
Syntax: ./$(basename "$0") --image <image> --env-file <file> [-h|--help] [--command <command>]

Launches a new background container for the given image.

Parameters:
  --image         - Image to be used.
  --env-file      - File containing the required environment variables.

Options:
  -h|--help       - Print this help.
  --command       - Command to be executed (instead of entering the shell).
EOF
}

# ----------------------
# Command line arguments
# ----------------------

CMD=""
while (( $# )); do
  case "$1" in
  --image)
    shift
    IMAGE_NAME="$1"    
    ;;
  --extra-options)
    shift
    EXTRA_OPTIONS="$1"
    ;;
  --command)
    shift
    # Explicitly source the bitbake environment to execute the command in it, 
    # as we're running a non-interactive bash session.
    CMD="/bin/bash -c 'source ${BITBAKE_INIT_ENV} && $1'"    
    ;;
  --env-file)
    shift
    ENV_FILE="$1"
    ;;
  -h|--help)
    print_help
    exit 0
    ;;
  esac
  shift
done

if [[ -z "${IMAGE_NAME}" ]] || [[ -z "${ENV_FILE}" ]]; then
  echo "Not all required parameters were provided! See --help for details."
  exit 1
fi

# Also use the environment variables in this script
# shellcheck disable=SC1090
. "${ENV_FILE}" 

# ---------
# Execution
# ---------

readonly HOSTNAME="${IMAGE_NAME}"
readonly CONTAINER_NAME="run-${IMAGE_NAME}"

echo "# ------------------------------"
echo "# Launching build environment..."
echo "# ------------------------------"

if [[ -z "${MOUNT_VOLUME}" ]]; then
  MOUNT_VOLUME="${PROJECT_ROOT}:${PROJECT_ROOT}"
fi

DOCKER_RUN_CMD="docker run "

if [[ -z "${CMD}" ]]; then
  DOCKER_RUN_CMD="${DOCKER_RUN_CMD} -it"
fi

DOCKER_RUN_CMD="${DOCKER_RUN_CMD} --rm \
  --name ${CONTAINER_NAME} -h ${HOSTNAME} \
  --network host \
  --user ${USER} \
  --volume=${MOUNT_VOLUME} \
  --workdir=${PROJECT_ROOT} \
  --env-file ${ENV_FILE} \
  --env BB_ENV_EXTRAWHITE \
  ${EXTRA_OPTIONS} \
  ${IMAGE_NAME}:${RELEASE_TAG}"

if [[ -n "${CMD}" ]]; then
  DOCKER_RUN_CMD="${DOCKER_RUN_CMD} ${CMD}"
fi

eval "${DOCKER_RUN_CMD}"