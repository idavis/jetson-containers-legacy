#!make

DIST_DIR := $(CURDIR)/../../dist

PYTORCH_GIT_VERSION ?= v1.1.0
DOCKERFILE ?= INVALID
TORCH_CUDA_ARCH_LIST := INVALID
IMAGE ?= INVALID

# CUDA_ARCH
# jax: 7.2
# tx2: 6.2
# tx1: 5.3
# tk1: 3.2
# nano: 5.3

.PHONY: all

all: pytorch-1.1.0-l4t-28.3-jetpack-3.3

pytorch-1.1.0-l4t-28.3-jetpack-3.3: TORCH_CUDA_ARCH_LIST := 5.3;6.2
pytorch-1.1.0-l4t-28.3-jetpack-3.3: IMAGE := 28.3-tx2-jetpack-3.3
pytorch-1.1.0-l4t-28.3-jetpack-3.3: build-pytorch-1.1.0-l4t-28.3-jetpack-3.3

build-%:
	$(DOCKER) build $(DOCKER_BUILD_ARGS) \
					--build-arg IMAGE=$(REPO):$(IMAGE) \
					--build-arg PYTORCH_GIT_VERSION=$(PYTORCH_GIT_VERSION) \
					--build-arg TORCH_CUDA_ARCH_LIST="$(TORCH_CUDA_ARCH_LIST)" \
					-t $(REPO):$* \
					-f $(CURDIR)/$(DOCKERFILE) \
					$(DOCKER_CONTEXT)

	$(MKDIR) -p $(DIST_DIR)/$*
	rm -f $*.cid
	$(DOCKER) run --cidfile $*.cid $(REPO):$*
	$(DOCKER) cp $$(cat $*.cid):/pytorch/dist/torch-1.1.0a0+b90cbb8-cp36-cp36m-linux_aarch64.whl $(DIST_DIR)/$*/
	$(DOCKER) rm $$(cat $*.cid) && rm $*.cid
	$(DOCKER) image rm $(REPO):$*

