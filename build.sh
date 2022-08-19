#!/bin/bash -e
# ------------------
# build.sh
# 
# Builds the Docker images that can be used as an environment for the Yocto build.
#
# Notes:
# - Uses the new Docker BuildKit to optimize image building and to provide nicer output
# ------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
readonly SCRIPT_DIR
readonly DOCKER_DIR="${SCRIPT_DIR}/docker"
. "${SCRIPT_DIR}/common.inc"

function print_help()
{
  cat <<EOF 
Syntax: ./$(basename "$0") --env-file <file> [-h|--help] [--no-cache] [--base-only] [--reuse-base] [--skip-yocto-build] [--export]

Builds the Docker images that can be used as an environment for the Yocto build.

Parameters:
  --env-file            - File containing the required environment variables.

Options:
  -h|--help             - Print this help.
  --no-cache            - Do not use the Docker build-cache.
  --base-only           - Only build the base image (without prebuilt sources).
  --reuse-base          - Reuse an existing base image.
  --skip-yocto-build    - Do not run the Yocto build.      
  --export              - Export the created images.
EOF
}

# ----------------------
# Command line arguments
# ----------------------

while (( $# )); do
  case "$1" in
  --no-cache)
    NO_CACHE="yes"
    ;;
  --base-only)
    BASE_ONLY="yes"
    ;;
  --reuse-base)
    REUSE_BASE="yes"
    ;;
  --skip-yocto-build)
    SKIP_YOCTO_BUILD="yes"
    ;;
  --export)
    shift
    EXPORT_DIR="$1"    
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

if [[ -z "${ENV_FILE}" ]]; then
  echo "Not all required parameters were provided! See --help for details."
  exit 1
fi

# Also use the environment variables in this script
# shellcheck disable=SC1090
. "${ENV_FILE}"

# ---------
# Functions
# ---------

function build_base_image()
{
  # Determine the (relative) paths to the docker resources init script directory
  local init_dir
  init_dir="$(realpath --relative-to="${PROJECT_ROOT}" "${DOCKER_DIR}/init.d")"

  echo "> Building the '${DOCKER_BASE_IMAGE_NAME}' Docker image..."
  time DOCKER_BUILDKIT=1 docker build \
    --file "${DOCKER_DIR}"/Dockerfile_yocto-base-env \
    --build-arg IMAGE_FROM="${DOCKER_BASE_FROM}" --build-arg DEV_USER="${USER}" --build-arg INIT_DIR="${init_dir}" \
    --tag "${DOCKER_BASE_IMAGE_NAME}:${RELEASE_TAG}" \
    "${options[@]}" .
  local result="$?"

  if [[ "${result}" == "0" ]]; then echo ">> Successfully build image. You can find it using the command 'docker images'."; else echo ">> Image building failed."; exit 1; fi

  if [[ -n "${EXPORT_DIR}" ]]; then
    "${SCRIPT_DIR}"/export.sh "${DOCKER_BASE_IMAGE_NAME}:${RELEASE_TAG}" "${EXPORT_DIR}"
  fi
}

function build_extended_image()
{
  if [[ ! "${SKIP_YOCTO_BUILD}" == "yes" ]]; then
    echo "> Running Yocto build to prepopulate image..."
    "${SCRIPT_DIR}"/launch.sh --image "${DOCKER_BASE_IMAGE_NAME}" --env-file "${ENV_FILE}" --command "bitbake core-image-base"
  fi

  echo "> Creating a temporary Docker build context to limit the amount of data sent to the daemon..."
  local pwd_before="${PWD}"
  local build_results_path="${PROJECT_ROOT}/${BUILD_DIR}"
  local tmp_context_path="${build_results_path}/docker-build-context"
  mkdir -p "${tmp_context_path}"
  # Move in Yocto build artifacts
  mv "${build_results_path}"/downloads "${tmp_context_path}"
  mv "${build_results_path}"/sstate-cache "${tmp_context_path}"
  # Copy the init.d resources into the build context and determine relative paths
  cp -r "${DOCKER_DIR}"/init.d "${tmp_context_path}"

  cd "${tmp_context_path}"

  echo "> Populating the '${DOCKER_PREBUILT_IMAGE_NAME}' Docker image..."
  time DOCKER_BUILDKIT=1 docker build \
    --file "${DOCKER_DIR}"/Dockerfile_yocto-prebuilt-env \
    --build-arg IMAGE_FROM="${DOCKER_BASE_IMAGE_NAME}:${RELEASE_TAG}" --build-arg DEV_USER="${USER}" \
    --tag "${DOCKER_PREBUILT_IMAGE_NAME}:${RELEASE_TAG}" \
    "${options[@]}" .
  local result="$?"

  echo "> Cleaning up temporary Docker build context..."
  cd "${pwd_before}"
  mv "${tmp_context_path}"/downloads "${build_results_path}"
  mv "${tmp_context_path}"/sstate-cache "${build_results_path}"
  rm -rfd "${tmp_context_path}"

  if [[ "${result}" == "0" ]]; then 
    echo ">> Successfully build image. You can find it using the command 'docker images'."
  else 
    echo ">> Image building failed."
    exit 1
  fi

  if [[ -n "${EXPORT_DIR}" ]]; then
    "${SCRIPT_DIR}"/export.sh "${DOCKER_PREBUILT_IMAGE_NAME}:${RELEASE_TAG}" "${EXPORT_DIR}"
  fi
}

# --------
# Building
# --------

# Be sure to run the build from the parent directory as we need all resources to be in the build context
cd "${PROJECT_ROOT}"

options=()
[[ "${NO_CACHE}" == "yes" ]] && options+=("--no-cache")

echo "# Base image build #"
[[ ! "${REUSE_BASE}" == "yes" ]] && build_base_image || echo "> Skipped due to '--reuse-base' option."

echo "# Extended image build #"
if [[ "${BASE_ONLY}" == "yes" ]]; then 
  echo "> Skipped due to '--base-only' option."
  exit 0
fi

build_extended_image

echo
echo "> All images successfully built. Start using them by running 'init.sh'..."

