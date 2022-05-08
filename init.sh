#!/bin/bash
# ------------------
# init.sh
# 
# Enters and initializes the Yocto build environment.
#
# ------------------
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
. "${SCRIPT_DIR}/common.inc"

function print_help()
{
  cat <<EOF 
Syntax: ./$(basename "$0") --env-file <file> [-h|--help] [--use-prebuilt] [<command>]

Enters and initializes the Yocto build environment.

Parameters:
  --env-file            - File containing the required environment variables.

Any additional positional arguments are passed to the environment to be executed in a one-shot manner.

Options:
  -h|--help             - Print this help.
  --use-prebuilt        - Use the image including prebuilt sources.
EOF
}

# ----------------------
# Command line arguments
# ----------------------

POSITIONAL_ARGS=()
while (( $# )); do
  case "$1" in
  --env-file)
    shift
    ENV_FILE="$1"    
    ;;
  --use-prebuilt)
    USE_PREBUILT="yes"
    ;;
  --help)
    print_help
    exit 0
    ;;
  *)
    POSITIONAL_ARGS+=("$1")
    ;;
  esac
  shift
done

DOCKER_IMAGE="${DOCKER_BASE_IMAGE_NAME}"
if [[ "${USE_PREBUILT}" == "yes" ]]; then
  DOCKER_IMAGE="${DOCKER_PREBUILT_IMAGE_NAME}"
fi

LAUNCH_CMD="${SCRIPT_DIR}/launch.sh --image ${DOCKER_IMAGE} --env-file ${ENV_FILE}"
if [[ "${#POSITIONAL_ARGS[@]}" != "0" ]]; then
  LAUNCH_CMD="${LAUNCH_CMD} --command \"${POSITIONAL_ARGS[@]}\""
fi
eval "${LAUNCH_CMD}"

