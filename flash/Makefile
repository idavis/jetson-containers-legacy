#!make

# Allow override for moby or another runtime
export DOCKER ?= docker

export REPO ?= l4t
export IMAGE_NAME ?= $(REPO)

# Used for creating the flashing container.
export VERSION_ID ?= bionic-20190307

# Allow additional options such as --squash
# DOCKER_BUILD_ARGS ?= ""
export DOCKER_CONTEXT ?= .

.PHONY: all

all: bionic-server-20190402 jetpack-bases

jetpack-bases: jetpack-4.1.1-bases jetpack-3.3-bases jetpack-3.2.1-bases

jetpack-3.2.1-bases: l4t-28.2-tx1-jetpack-3.2.1-base l4t-28.2.1-tx2-jetpack-3.2.1-base 

jetpack-3.3-bases: l4t-28.2-tx1-jetpack-3.3-base l4t-28.3-tx1-jetpack-3.3-base l4t-28.2.1-tx2-jetpack-3.3-base l4t-28.3-tx2-jetpack-3.3-base

jetpack-4.1.1-bases: l4t-31.1-jax-jetpack-4.1.1-base

l4t-28.2-tx1-jetpack-3.2.1-base:
	$(CURDIR)/build_from_make.sh $(CURDIR)/jetpack-bases/$@ $(REPO):$@

l4t-28.2-tx1-jetpack-3.2.1-base:
	$(CURDIR)/build_from_make.sh $(CURDIR)/jetpack-bases/$@ $(REPO):$@

l4t-31.1-jax-jetpack-4.1.1-base:
	$(CURDIR)/build_from_make.sh $(CURDIR)/jetpack-bases/$@ $(REPO):$@

l4t-28.2-tx1-jetpack-3.3-base:
	$(CURDIR)/build_from_make.sh $(CURDIR)/jetpack-bases/$@ $(REPO):$@

l4t-28.2.1-tx2-jetpack-3.2.1-base:
	$(CURDIR)/build_from_make.sh $(CURDIR)/jetpack-bases/$@ $(REPO):$@

l4t-28.3-tx1-jetpack-3.3-base:
	$(CURDIR)/build_from_make.sh $(CURDIR)/jetpack-bases/$@ $(REPO):$@

l4t-28.2.1-tx2-jetpack-3.3-base:
	$(CURDIR)/build_from_make.sh $(CURDIR)/jetpack-bases/$@ $(REPO):$@

l4t-28.3-tx2-jetpack-3.3-base:
	$(CURDIR)/build_from_make.sh $(CURDIR)/jetpack-bases/$@ $(REPO):$@

bionic-server-20190402 : $(addprefix bionic-server-20190402-,31.1 28.3)

bionic-server-20190402-31.1: $(addprefix bionic-server-cloudimg-20190402-31.1-,jax)

bionic-server-20190402-28.3: $(addprefix bionic-server-cloudimg-20190402-28.3-,tx2 tx1)

bionic-server-cloudimg-20190402-%:	
	$(CURDIR)/build_from_make.sh $(CURDIR)/rootfs/bionic-server-cloudimg-20190402.conf $(CURDIR)/drivers/$*.conf $(REPO):$@
