
default: runner.image

.PHONY: requirements.txt
requirements.txt:
	pip freeze  --all  --local --exclude-editable > $@

BUILD_ARGS=--build-arg GOOGLE_CREDENTIALS_FILE=$(GOOGLE_CREDENTIALS_FILE)\
--build-arg GOOGLE_APPLICATION_CREDENTIALS=$(GOOGLE_APPLICATION_CREDENTIALS)\
--build-arg GOOGLE_CLOUD_PROJECT=$(GOOGLE_CLOUD_PROJECT)\
--build-arg PUBSUB_TOPIC=$(PUBSUB_TOPIC)\
--build-arg PUBSUB_SUBSCRIPTION=$(PUBSUB_SUBSCRIPTION)\
--build-arg DJR_DOCKER_SCRATCH=$(DJR_DOCKER_SCRATCH)\
--build-arg THIS_DOCKER_IMAGE=$(IMAGE_NAME)

IMAGE_VERSION=s21-dev
DOCKER_DEVEL_IMAGE=cse142l-dev:$(IMAGE_VERSION)
DOCKER_CORE_IMAGE=cse142l-core:$(IMAGE_VERSION)
DOCKER_RUNNER_IMAGE=cse142l-runner:$(IMAGE_VERSION)
DOCKER_SERVICE_IMAGE=cse142l-service:$(IMAGE_VERSION)
DOCKER_USER_IMAGE=cse142l-user:$(IMAGE_VERSION)
DEVEL_ROOT=$(PWD)

#djr-docker-job.image: IMAGE_NAME=djr-docker-job

core.image: IMAGE_NAME=$(DOCKER_CORE_IMAGE)
dev.image: IMAGE_NAME=$(DOCKER_DEVEL_IMAGE)
runner.image: IMAGE_NAME=$(DOCKER_RUNNER_IMAGE)
service.image: IMAGE_NAME=$(DOCKER_SERVICE_IMAGE)
user.image: IMAGE_NAME=$(DOCKER_USER_IMAGE)


core.image:
dev.image: core.image
service.image: dev.image
runner.image : dev.image

ifeq ($(FROM_SCRATCH),yes)
BUILD_OPTS=--no-cache
endif

%.image: %.docker
#>ifneq ($(REBUILD),yes)
#		@[ "$$(docker images -q $(IMAGE_NAME))." = "." ] || (echo  "$(IMAGE_NAME) already exists\n\n" && false)
#	endif
	docker build --file $< -t $(IMAGE_NAME) --build-arg DOCKER_IMAGE=$(IMAGE_NAME) --build-arg DEVEL_ROOT=$(DEVEL_ROOT) $(BUILD_ARGS) $(BUILD_OPTS) .
	docker tag $(IMAGE_NAME) $(subst $(IMAGE_VERSION),latest,$(IMAGE_NAME))
	touch $@

.PHONY: clean
clean:
	rm -rf *.image

.PHONY:test
test:
	$(MAKE) -C CSE141pp-DJR test
	$(MAKE) -C CSE141pp-LabPython test

