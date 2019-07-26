#!make

31.1-jax-jetpack-4.1.1:
	$(DOCKER) build $(DOCKER_BUILD_ARGS) \
					--build-arg IMAGE_NAME=$(IMAGE_NAME) \
					-t $(REPO):$@ \
					-f 4.1.1/jax/Dockerfile \
					$(DOCKER_CONTEXT)

%-tx2-jetpack-3.3:
	$(DOCKER) build $(DOCKER_BUILD_ARGS) \
					--build-arg IMAGE_NAME=$(IMAGE_NAME) \
					--build-arg L4T_VERSION=$* \
					-t $(REPO):$@ \
					-f 3.3/tx2/Dockerfile \
					$(DOCKER_CONTEXT)

%-tx1-jetpack-3.3:
	$(DOCKER) build $(DOCKER_BUILD_ARGS) \
					--build-arg IMAGE_NAME=$(IMAGE_NAME) \
					--build-arg L4T_VERSION=$* \
					-t $(REPO):$@ \
					-f 3.3/tx1/Dockerfile \
					$(DOCKER_CONTEXT)

%-tx2-jetpack-3.2.1:
	$(DOCKER) build $(DOCKER_BUILD_ARGS) \
					--build-arg IMAGE_NAME=$(IMAGE_NAME) \
					--build-arg L4T_VERSION=$* \
					-t $(REPO):$@ \
					-f 3.2.1/tx2/Dockerfile \
					$(DOCKER_CONTEXT)

%-tx1-jetpack-3.2.1:
	$(DOCKER) build $(DOCKER_BUILD_ARGS) \
					--build-arg IMAGE_NAME=$(IMAGE_NAME) \
					--build-arg L4T_VERSION=$* \
					-t $(REPO):$@ \
					-f 3.2.1/tx1/Dockerfile \
					$(DOCKER_CONTEXT)

