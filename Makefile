.PHONY: default
default: runner.image dev.image core.image service.image dsmlp.image

.PHONY: setup
setup:
	pip install -e .
	python -m pip install -e .

#.PHONY: requirements.txt
#requirements.txt: 
#	pip freeze  --all  --local --exclude-editable | grep -v DJR | grep -v LabPython  | grep -v pygobject | grep -v python-apt > $@
#	#	python -m pip freeze  --all  --local --exclude-editable jupyter_requirements.txt

BUILD_ARGS=--build-arg GOOGLE_CREDENTIALS_FILE=$(GOOGLE_CREDENTIALS_FILE)\
--build-arg GOOGLE_APPLICATION_CREDENTIALS=$(GOOGLE_APPLICATION_CREDENTIALS)\
--build-arg GOOGLE_CLOUD_PROJECT=$(GOOGLE_CLOUD_PROJECT)\
--build-arg DJR_DOCKER_SCRATCH=$(DJR_DOCKER_SCRATCH)\
--build-arg DOCKER_DEVEL_IMAGE=$(DOCKER_DEVEL_IMAGE)\
--build-arg DOCKER_CORE_IMAGE=$(DOCKER_CORE_IMAGE)\
--build-arg DOCKER_RUNNER_IMAGE=$(DOCKER_RUNNER_IMAGE)\
--build-arg DOCKER_SERVICE_IMAGE=$(DOCKER_SERVICE_IMAGE)\
--build-arg DOCKER_BASE_IMAGE=$(DOCKER_BASE_IMAGE) \
--build-arg CLOUD_MODE=$(CLOUD_MODE) \
--build-arg DJR_SERVER=$(DJR_SERVER) \
--build-arg ARCHLAB_ROOT=$(ARCHLAB_ROOT) \
--build-arg PIN_ROOT=$(PIN_ROOT) \
--build-arg MONETA_ROOT=$(MONETA_ROOT) \
--build-arg CANELA_ROOT=$(CANELA_ROOT) \
--build-arg DJR_JOB_TYPE=$(DJR_JOB_TYPE) \
--build-arg JUPYTER_CONFIG_DIR=$(JUPYTER_CONFIG_DIR) \
--build-arg DJR_CLUSTER=$(DJR_CLUSTER)

SUBDIRS=cse141pp-archlab CSE141pp-LabPython CSE141pp-DJR CSE141pp-Tool-Moneta CSE141pp-SimpleCNN CSE141pp-Tool-Moneta-Pin
export SUBDIRS


core.image: IMAGE_NAME=$(DOCKER_CORE_IMAGE)
dev.image: IMAGE_NAME=$(DOCKER_DEVEL_IMAGE)
runner.image: IMAGE_NAME=$(DOCKER_RUNNER_IMAGE)
base.image: IMAGE_NAME=$(DOCKER_BASE_IMAGE)
service.image: IMAGE_NAME=$(DOCKER_SERVICE_IMAGE)
dsmlp.image: IMAGE_NAME=$(DOCKER_DSMLP_IMAGE)
test.image: IMAGE_NAME=test-image
test2.image: IMAGE_NAME=test2-image

IMAGES=$(DOCKER_DEVEL_IMAGE) $(DOCKER_CORE_IMAGE) $(DOCKER_RUNNER_IMAGE) $(DOCKER_SERVICE_IMAGE) $(DOCKER_USER_IMAGE) $(DOCKER_DSMLP_IMAGE)

atest:
	echo $(IMAGES)
core.image:
dev.image: service.image
service.image: base.image
base.image: core.image
runner.image : base.image
dsmlp.image: service.image

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
	docker build --progress plain --file $< -t $(IMAGE_NAME) --build-arg ARG_THIS_DOCKER_IMAGE=$(IMAGE_NAME) --build-arg CSE142L_ROOT=$(CSE142L_ROOT) $(BUILD_ARGS) $(BUILD_OPTS) --build-arg ARG_THIS_DOCKER_IMAGE_UUID=$(shell uuidgen) .
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
	(. .bootstrap-venv/bin/activate; pip install wheel;cd CSE141pp-LabPython; make setup; cd ../CSE141pp-DJR; make setup)

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
	-for i in $(IMAGES); do docker pull $$i; done
	-for i in $(subst :$(DOCKER_IMAGE_VERSION),:latest,$(IMAGES)); do docker pull $$i; done


DOCKER_STACKS_DEP_CHAIN=base-notebook minimal-notebook scipy-notebook

.PHONY: docker-stacks
docker-stacks:
	[ -d docker-stacks ] || git clone https://github.com/jupyter/docker-stacks.git
	for i in $(DOCKER_STACKS_DEP_CHAIN); do $(MAKE) -C docker-stacks build/$$i OWNER=stevenjswanson DARGS="--build-arg PYTHON_VERSION=3.7 --no-cache"; done
	for i in $(DOCKER_STACKS_DEP_CHAIN); do $(MAKE) -C docker-stacks push/$$i  OWNER=stevenjswanson ;done


