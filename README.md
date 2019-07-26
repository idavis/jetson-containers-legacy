# Jetson Containers Legacy

For running modern versions of Jetson/JetPack containers, please use the [jetson-conatiners](https://github.com/idavis/jetson-containers/) repository.

This repository is maintained for posterity.

## Table of Contents

1. [Preface](#preface)
2. [Introduction](#introduction)
3. [Configuration](#configuration)
4. [Building](#building)
5. [Running](#running)
6. [OpenCV](#opencv)
7. [Flashing Devices](#flashing-devices)
8. [Image Sizes](#image-sizes)

## Preface

This project provides a repeatable, containerized approach to building software and libraries to run on the Nvidia Jetson platforms 4.1.1 and prior.

## Introduction

When building your application and choosing a base, the JetPack images can be trimmed to only include what is needed by your application. This can drastically reduce the size of your images.

These containers enable the OS can be flashed without JetPack having only the main driver pack installed. The other libraries will be included in the containers enabling migration and updates without involving the host operating system.

When building third party libraries, such as OpenCV and PyTorch, a swapfile will *likely* have to be created in the host OS. These packages require more memory than the system contains and will crash with very cryptic errors if they run out of memory.

Each image, whether Linux for Tegra (L4T) or JetPack based provides args for the `URL` to pull installers from. Once the JetPack installer has been run, copy the packages to your own source for downloading. This will likely increase your download speed and allow building images if the package URLs ever change.

## Configuration

### The .env File

The `Makefile` scripts will import a `.env` file (for an example look at the `.envtemp` file) and export the variables defined.

- `REPO` - This is for your own container registry/repo. The builds will take care of the tags and images names. For example `REPO=mycontainers.azurecr.io/l4t`
- `DOCKER` - Allows swapping out for another container runtime such as Moby or Balena. This variable is used in all container operations.
- `DOCKER_HOST` - Setting the `DOCKER_HOST` variable will proxy builds to another machine such as a Jetson device. This allows running the `make` scripts from an `x86_x64` host. This feature was added in November 2018. When using this feature, it is helpful to add your public key to the device's `~/.ssh/authorized_keys` file. This will prevent credential checks on every build.
- `DOCKER_BUILD_ARGS` - Allows adding arguments such as volume mounting or cleanup (`-rm/--squash`) during build operations.
- `DOCKER_RUN_ARGS` -  Allows adding arguments such as environment variables, mounts, network configuration, etc when running images. Can also be used to configure X11 forwarding.
- `DOCKER_CONTEXT` - Defaults to `.` but can be overridden in some circumstances for testing.

### Docker

Storing these images will also require significant disk space. It is highly recommended that an NVME or other hard drive is installed and mounted at boot through `fstab`. Once mounted, configure your container runtime to store its containers and images there. You'll also want to enable the experimental features to get `--squash` available during builds. This can be turned off by manually specifying `DOCKER_BUILD_ARGS`.

`/etc/docker/daemon.json`
```json
{
    "data-root": "/some/external/docker",
    "experimental": true
}
```

## Building

The project uses `make` to set up the dependent builds constructing the final images. The recipes fall into a few categories:

- Driver packs (32.1, 31.,1 28.3, 28.2.1, 28.2, 28.1)
- JetPack (4.1.1, 3.3, 3.2.1)
- Devices (jax (xavier), tx2, tx1)
- Flashing containers
- OpenCV (4.0.1)

### Driver Packs

The driver packs form the base of the device images. Each version of JetPack is built on top of a driver pack. To build an image, follow the pattern:

`make <driver-pack>-<device>-jetpack-<jetpack-version>`

Note: not all combinations are valid and the `Makefile` should have all valid combinations declared.
Note: if these command's are not run on the device, the `DOCKER_HOST` variable must be set.

examples:

```bash
make driver-packs # build all driver pack bases
make 28.3-tx2-jetpack-3.3
make 28.2.1-tx2-jetpack-3.2.1
make 28.2-tx1-jetpack-3.2.1
```

## Running

To run a container with GPU support there are two options. First, not recommended, run with the `--privileged` option. Second, recommended option, is to add the host's GPUs to the container:

```bash
docker run \
    --device=/dev/nvhost-ctrl \
    --device=/dev/nvhost-ctrl-gpu \
    --device=/dev/nvhost-prof-gpu \
    --device=/dev/nvmap \
    --device=/dev/nvhost-gpu \
    --device=/dev/nvhost-as-gpu \
    --device=/dev/nvhost-vic \
    <image-name>
```

### X11 Forwarding

Running containerized applications with X11 forwarding requires simple configuration changes

- On the host OS, run `xhost +local:docker`
- Add `--net=host` and `-e "DISPLAY"` arguments to docker

The `DOCKER_RUN_ARGS` variable can be set in the `.env` file to `DOCKER_RUN_ARGS=--net=host -e "DISPLAY"` which will set up the forwarding when using `make`. 

## OpenCV

Building OpenCV can take a few hours depending on your device and performance mode. When the OpenCV builds are complete, the install `.sh` file can be found in the `/dist` folder.

### Building OpenCV

```
make opencv-4.0.1-l4t-28.3-jetpack-3.3
```

## Flashing Devices

Flashing devices usually requires installation of JetPack. To make this easier and more repeatable, you can now flash your device using a container. 

There are default profiles which match the device and JetPack versions in the `flash/jetpack-bases` folder. Once the image is created, you have a versionable image which will be the base OS and drivers for your device. 

Examples:
```bash
make image-bionic-server-20190402 # Set up an image which can flash bionic server to the device
make image-jetpack-bases # create all jetpack default configuration images for flashing.
make image-l4t-28.3-tx2-jetpack-3.3-base # JetPack 3.3 for TX2 with driver pack 28.3
```

Note: Ensure that if the `DOCKER_HOST` variable is set, the host specified must be `x86_64`.
Note: The `Dockerfile`s can be modified to chroot the rootfs folder customizing the image such as setting up `cloud-init`.

To flash the device, put the device into recovery mode and connect it to the host via USB cable. You can follow the instructions from your device instructions, or run `reboot recovery` from a terminal session on the device. Now, run `./flash.sh` along with the image tag you want to execute. For example, looking at images previously built:

```bash
>:~/jetson-containers/flash$ docker images
REPOSITORY                           TAG                 IMAGE ID            CREATED             SIZE
l4t:28.3-tx2-jetpack-3.3-base        latest              cc58f9478aa2        22 hours ago        3.35GB
```

We can flash the tx2 with the default JetPack 3.3 configuration by executing `./flash.sh l4t-28.3-tx2-jetpack-3.3-base`. If your device is not in recovery mode, you will see an error similar to:

```
###############################################################################
# L4T BSP Information:
# R31 (release), REVISION: 1.0, GCID: 13194883, BOARD: t186ref, EABI: aarch64, 
# DATE: Wed Oct 31 22:26:16 UTC 2018
###############################################################################
Error: probing the target board failed.
       Make sure the target board is connected through 
       USB port and is in recovery mode.
```

If your device was in recovery mode, you should see progress displayed. Once the device has been flashed, it will automatically restart.

## Image sizes

### Base

| Repository | Tag | Size |
|---|---|---|
| arm64v8/ubuntu | bionic-20190612 | 80.4MB |
| arm64v8/ubuntu | xenial-20190610 | 108MB |

### Jetson

#### Driver packs:

| Repository | Driver | Size |
|---|---|---|
| l4t | 28.1-tx1 | 371MB |
| l4t | 28.1-tx2 | 435MB |
| l4t | 28.2.1-tx2 | 460MB |
| l4t | 28.2-tx1 | 414MB |
| l4t | 28.3-tx1 | 459MB |
| l4t | 28.3-tx2 | 551MB |
| l4t | 31.1-jax | 370MB |
| l4t | 32.1-jax | 479MB |
| l4t | 32.1-nano-dev | 469MB |
| l4t | 32.1-tx2 | 479MB |
| l4t | 32.2-jax | 493MB |

#### JetPack 4.1.1

| Repository | Tag | Size |
|---|---|---|
| l4t | 31.1-jax-jetpack-4.1.1 | 5.61GB |

#### JetPack 3.3

| Repository | Tag | Size |
|---|---|---|
| l4t | 28.3-tx1-jetpack-3.3 | 4.48GB |
| l4t | 28.3-tx2-jetpack-3.3 | 4.58GB |
| l4t | 28.2.1-tx2-jetpack-3.3 | 4.47GB |
| l4t | 28.2-tx1-jetpack-3.3 | 4.43GB |

#### JetPack 3.2.1

| Repository | Tag | Size |
|---|---|---|
| l4t | 28.3-tx1-jetpack-3.2.1 | 4.09GB |
| l4t | 28.3-tx2-jetpack-3.2.1 | 4.18GB |
| l4t | 28.2.1-tx2-jetpack-3.2.1 | 4.08GB |
| l4t | 28.2-tx1-jetpack-3.2.1 | 4.03GB |
