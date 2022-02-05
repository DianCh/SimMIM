WORK_DIR=${PWD}
DOCKER_IMAGE=simmim:latest
DOCKER_FILE=Dockerfile

DOCKER_OPTS = \
	-it \
	--rm \
	-e DISPLAY=${DISPLAY} \
	-v ~/datasets:/datasets \
	-v /tmp:/tmp \
	-v /tmp/.X11-unix:/tmp/.X11-unix \
	-v /mnt/fsx:/mnt/fsx \
	-v ~/.ssh:${HOME}/.ssh \
	-v ~/.aws:${HOME}/.aws \
	-v ${WORK_DIR}:${HOME}/workspace \
	--shm-size=1G \
	--ipc=host \
	--network=host \
	--pid=host \
	--privileged

docker-dev:
	nvidia-docker run --name $(NAME) \
	$(DOCKER_OPTS) \
	$(DOCKER_IMAGE) bash

build:
	nvidia-docker image build -f $(DOCKER_FILE) -t $(DOCKER_IMAGE) \
	--build-arg USER=$(USER) \
	--build-arg USER_ID=$(shell id -u) \
	--build-arg GROUP_ID=$(shell id -g) .

clean:
	find . -name '"*.pyc' | xargs sudo rm -f && \
	find . -name '__pycache__' | xargs sudo rm -rf