
default: core.image dev.image
.PHONY: %.image

BUILD_ARGS=--build-arg GOOGLE_APPLICATION_CREDENTIALS=$(GOOGLE_APPLICATION_CREDENTIALS)

# --build-arg GITHUB_OAUTH_TOKEN \
# --build-arg DOCKER_DEVEL_IMAGE \
# --build-arg DOCKER_STUDENT_IMAGE \
# --build-arg CONFIG_REPO_ROOT_NAME=$(CONFIG_REPO_ROOT_NAME) \
# --build-arg DOCKER_RUNNER_IMAGE \
# --build-arg CONFIG_REPO_ROOT \
# --build-arg IN_DEPLOYMENT \
# --build-arg GIT_BRANCH \
# --build-arg RUNLAB_STATUS_DIRECTORY \
# --build-arg CLOUD_MODE=CLOUD

IMAGE_VERSION=s21-dev
DOCKER_DEVEL_IMAGE=cse142-dev:$(IMAGE_VERSION)
DOCKER_CORE_IMAGE=cse142-core:$(IMAGE_VERSION)
DEVEL_ROOT=$(PWD)

dev.image: IMAGE_NAME=$(DOCKER_DEVEL_IMAGE)
core.image: IMAGE_NAME=$(DOCKER_CORE_IMAGE)

ifeq ($(FROM_SCRATCH),yes)
BUILD_OPTS=--no-cache
endif

%.image: %.docker
#>ifneq ($(REBUILD),yes)
#		@[ "$$(docker images -q $(IMAGE_NAME))." = "." ] || (echo  "$(IMAGE_NAME) already exists\n\n" && false)
#	endif
	docker build --file $< -t $(IMAGE_NAME) --build-arg DOCKER_IMAGE=$(IMAGE_NAME) --build-arg DEVEL_ROOT=$(DEVEL_ROOT) $(BUILD_ARGS) $(BUILD_OPTS) .
	docker tag $(IMAGE_NAME) $(subst $(IMAGE_VERSION),latest,$(IMAGE_NAME))
