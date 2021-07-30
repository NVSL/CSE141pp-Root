.PHONY: default
default: runner.image dev.image core.image service.image

.PHONY: setup
setup:
	pip install -e .

.PHONY: require	ments.txt
requirements.txt:
	pip freeze  --all  --local --exclude-editable > $@

BUILD_ARGS=--build-arg GOOGLE_CREDENTIALS_FILE=$(GOOGLE_CREDENTIALS_FILE)\
--build-arg GOOGLE_APPLICATION_CREDENTIALS=$(GOOGLE_APPLICATION_CREDENTIALS)\
--build-arg GOOGLE_CLOUD_PROJECT=$(GOOGLE_CLOUD_PROJECT)\
--build-arg PUBSUB_TOPIC=$(PUBSUB_TOPIC)\
--build-arg PUBSUB_SUBSCRIPTION=$(PUBSUB_SUBSCRIPTION)\
--build-arg DJR_DOCKER_SCRATCH=$(DJR_DOCKER_SCRATCH)\
--build-arg THIS_DOCKER_IMAGE=$(IMAGE_NAME)\
--build-arg DOCKER_DEVEL_IMAGE=$(DOCKER_DEVEL_IMAGE)\
--build-arg DOCKER_CORE_IMAGE=$(DOCKER_CORE_IMAGE)\
--build-arg DOCKER_RUNNER_IMAGE=$(DOCKER_RUNNER_IMAGE)\
--build-arg DOCKER_SERVICE_IMAGE=$(DOCKER_SERVICE_IMAGE)#\
#--build-arg DOCKER_USER_IMAGE=$(DOCKER_USER_IMAGE)

#djr-docker-job.image: IMAGE_NAME=djr-docker-job

core.image: IMAGE_NAME=$(DOCKER_CORE_IMAGE)
dev.image: IMAGE_NAME=$(DOCKER_DEVEL_IMAGE)
runner.image: IMAGE_NAME=$(DOCKER_RUNNER_IMAGE)
service.image: IMAGE_NAME=$(DOCKER_SERVICE_IMAGE)
test.image: IMAGE_NAME=test-image
#user.image: IMAGE_NAME=$(DOCKER_USER_IMAGE)

IMAGES=$(DOCKER_DEVEL_IMAGE) $(DOCKER_CORE_IMAGE) $(DOCKER_RUNNER_IMAGE) $(DOCKER_SERVICE_IMAGE) $(DOCKER_USER_IMAGE)

core.image:
dev.image: service.image
service.image: runner.image
runner.image : core.image

test.image:

ifeq ($(CACHE),yes)
BUILD_OPTS=
else
BUILD_OPTS=--no-cache
endif

%.image: dockerfiles/%.docker
#>ifneq ($(REBUILD),yes)
#		@[ "$$(docker images -q $(IMAGE_NAME))." = "." ] || (echo  "$(IMAGE_NAME) already exists\n\n" && false)
#	endif
	docker build --progress plain --file $< -t $(IMAGE_NAME) --build-arg DOCKER_IMAGE=$(IMAGE_NAME) --build-arg CSE142L_ROOT=$(CSE142L_ROOT) $(BUILD_ARGS) $(BUILD_OPTS) --build-arg THIS_DOCKER_IMAGE_UUID=$(shell uuidgen) .
#2>&1 | tee $*.log
	docker tag $(IMAGE_NAME) $(subst $(DOCKER_IMAGE_VERSION),latest,$(IMAGE_NAME))
	touch $@

.PHONY: perms
perms:
	@echo $(DOCKER_ACCESS_TOKEN) | docker login  --password-stdin --username $(DOCKER_USERNAME) #>/dev/null 2>&1

.PHONY: clean
clean:
	rm -rf *.image


.PHONY:bootstrap
bootstrap:
	python3 -m venv ./.bootstrap-venv
	(. .bootstrap-venv/bin/activate; cd CSE141pp-LabPython; make setup; cd ../CSE141pp-DJR; make setup)

.PHONY:test
test:
	$(MAKE) -C CSE141pp-DJR test
	$(MAKE) -C CSE141pp-LabPython test

.PHONY: push
push: perms
	for i in $(IMAGES); do docker push $$i; done
	for i in $(subst :$(DOCKER_IMAGE_VERSION),:latest,$(IMAGES)); do docker push $$i; done

.PHONY: pull
pull: perms
	for i in $(IMAGES); do docker pull $$i; done
	for i in $(subst :$(DOCKER_IMAGE_VERSION),:latest,$(IMAGES)); do docker pull $$i; done

.PHONY: manifest.txt
manifest.txt:
	for d in . $(SUBDIRS); do (cd $$d;  echo =========== $$d ==============; git rev-parse HEAD; git status; git diff);done > $@

