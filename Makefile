IMAGE_NAME = pjc
GIT_VERSION := $(shell git describe --abbrev=7 --dirty --always --tags)


DOCKER = docker


docker:
	${DOCKER} build -t ${IMAGE_NAME} .
	${DOCKER} tag ${IMAGE_NAME} ${GIT_VERSION}