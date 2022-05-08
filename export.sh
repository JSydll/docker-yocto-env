#!/bin/bash -e
# ------------------
# export.sh
# 
# Exports a specified image to the given directory.
#
# ------------------
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

function print_help()
{
  cat <<EOF 
Syntax: ./$(basename "$0") <image> <directory> [-h|--help]

Exports a specified image to the given directory.

Positional arguments:
  - <image>       - Docker image name.
  - <directory>   - Target directory to export the image to.

Options:
  -h|--help       - Print this help.
EOF
}

# ----------------------
# Command line arguments
# ----------------------

if [[ " $* " =~ " --help " ]] || [[ " $* " =~ " -h " ]]; then
  print_help
  exit 0
fi

if [[ "$#" != "2" ]]; then
  echo "Please specify image name and export directory as command line parameters!"
  exit 1
fi

# Positional parameters
readonly IMAGE_NAME="$1"
readonly EXPORT_DIR="$2"

function docker_export_image()
{
  local image_name="$1"
  local export_dir="$2"

  echo "> Exporting the image '${image_name}' (this might take a while)..."

  local tar_file_name="docker.${image_name//:/_}.tar.gz"
  docker save ${image_name} | gzip > ${export_dir}/${tar_file_name} \
    && echo ">> Saved to '${export_dir}/${tar_file_name}'." \
    || echo ">> Failed to export image!"
}

docker_export_image ${IMAGE_NAME} ${EXPORT_DIR}