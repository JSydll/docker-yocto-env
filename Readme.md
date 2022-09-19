# Docker-based Yocto environment

This repository contains scripts to setup a Docker-based environment for Yocto builds. 
It's meant to be integrated into an arbitrary Yocto stack and can be configured via one env-var file (more on that below).


## Approach

As bash scripts are usually also a part of Yocto recipe development, this project only uses bash.

The provided scripts represent the primary use cases of setting up a development/build environment:

- Provisioning the host system (`setup-host.sh`)
- Building Docker images with all required dependencies (`build.sh`)
- Exporting Docker images to share them in a team (`export.sh`)
- Initializing and launching the build environment (`init.sh` and `launch.sh`)


### Base and prebuilt environments

To avoid long wait times when setting up the environment and running the build for the first time,
an extended Docker image can be built (in addition to a basic image with Yocto build dependencies),
containing prebuilt sources. Hence, these two image types can be used:

- the `yocto-base-env:<release>` image, a small image with all necessary requirements for building a distro of the given Yocto `<release>`. 
- the `yocto-prebuilt-env:<release>` image, containing the most important build outcomes.

To avoid conflicts with resources on the host filesystem, the prebuilt ones are moved into the `build` 
directory only if nothing was present there yet (this seemed to be the easieast ways instead of setting up a complex overlay). 
This is done by the `docker/init.d/prebuilt.sh` scropt on first run of a container spawned from the prepopulated image.

### Entering vs executing one-shot containers

The `launch.sh` script supports two ways to use the build environments:

- Spawning a container and entering it - this is the default way to use the environment as it allows to stay in the fully initialized
  bitbake environment.
- In some cases, it might be desired to only run one command within the environment and then leave it again. This is possible by providing
  the `--command <command>` parameter to the `launch.sh` script. 


## System requirements

The main requirements to use this environment are

- `bash`, and
- `Docker` (see [official documentation](https://docs.docker.com/engine/install/) for guidance how to install Docker).

They will be installed when you use the `./setup-host.sh` script.

For development, it is also recommended to use `shellcheck` for clean scripting.
Run it with `shellcheck ./*.sh ./*.inc` on this code base.

The setup was tested on

- `Ubuntu 20.04` and `Ubuntu 22.04`.


## Integration

The straight forward way to integrate the environment into a Yocto stack is to load this repo as `git submodule`. 

For a proper mounting of host sources and setup of the environment initalization, an env-var file must be provided.
Please refer to `integration/env.example` for the syntax and required environment variables.
Additional variables defined there will also be visible in the build environment.

Note: The special variable `BB_ENV_EXTRAWHITE` will be exported to the build environment by default.

For compatibility reasons, avoid the usage of quotes in the assignment of environment variables in the `.env` file.


## Usage

All scripts provide a `--help` option showing more detailed information on their usage.

For a quickstart, simply setup your Linux host system via the `setup-host.sh` script, build a base image for running bitbake
with `build.sh --env-file <path-to-file> --base-only` and enter the environment with `init.sh env-file <path-to-file>`.

If you want to `launch.sh` the environment from a branch different than one of the supported main branches,
be sure to **set the `RELEASE_TAG` variable with the desired branch/release** as this is used to determine
the tag of the image to be started.

## Branching

Aligned with the Yocto project, supported Yocto releases are reflected in the branches of this repo.
The currently supported releases are:

- _dunfell_

The branch name is also used to tag the built images.


## Known limitations

As of now, there are a few limitations of the implementation:

- Sharing the (prebuilt) environment will only work if host systems _share the same user_ as 
  **the user running the Docker image build will be setup within the image as well**.


## Supported platforms

Currently, the environment is only tested on **Ubuntu-based host systems**. 


## Contributions

Contributions are warmly welcomed. Please reach out to the repository maintainer.