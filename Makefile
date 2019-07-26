#!make

include $(CURDIR)/.env
export $(shell sed 's/=.*//' .env)

# Allow override for moby or another runtime
export DOCKER ?= docker

export MKDIR ?= mkdir

export REPO ?= l4t
export IMAGE_NAME ?= $(REPO)

# Used in driver pack base
export BIONIC_VERSION_ID ?= bionic-20190612
export XENIAL_VERSION_ID ?= xenial-20190610

# Allow additional options such as --squash
# DOCKER_BUILD_ARGS ?= ""
export DOCKER_CONTEXT ?= .

export SDKM_DOWNLOADS ?= invalid

.PHONY: all

all: driver-packs jetpacks

driver-packs: $(addprefix driver-pack-,31.1 28.3 28.2.1 28.2 28.1)

driver-pack-31.1: $(addprefix l4t-31.1-,jax)

driver-pack-28.3: $(addprefix l4t-28.3-,tx2 tx1)

driver-pack-28.2.1: $(addprefix l4t-28.2.1-,tx2)

driver-pack-28.2: $(addprefix l4t-28.2-,tx1)

driver-pack-28.1: $(addprefix l4t-28.1-,tx2 tx1)

l4t-%:
	make -C $(CURDIR)/docker/l4t $*

jetpacks: $(addprefix jetpack-,4.1.1 3.3 3.2.1)

jetpack-4.1.1: 31.1-jax-jetpack-4.1.1

jetpack-3.3: 28.3-tx2-jetpack-3.3 28.3-tx1-jetpack-3.3 28.2.1-tx2-jetpack-3.3 28.2-tx1-jetpack-3.3

jetpack-3.2.1: 28.3-tx2-jetpack-3.2.1 28.3-tx1-jetpack-3.2.1 28.2.1-tx2-jetpack-3.2.1 28.2-tx1-jetpack-3.2.1

%-jetpack-4.1.1:l4t-%
	make -C $(CURDIR)/docker/jetpack $@

%-jetpack-3.3: l4t-%
	make -C $(CURDIR)/docker/jetpack $@

%-jetpack-3.2.1: l4t-%
	make -C $(CURDIR)/docker/jetpack $@

image-%:
	make -C $(CURDIR)/flash $*

opencv-4.0.1-l4t-28.3-jetpack-3.3:
	make -C $(CURDIR)/docker/OpenCV $@

pytorch-1.1.0-l4t-28.3-jetpack-3.3:
	make -C $(CURDIR)/docker/pytorch $@
