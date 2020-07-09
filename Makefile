# set default shell
SHELL := $(shell which bash)
FOLDER=$$(pwd)
# default shell options
.SHELLFLAGS = -c
PORT=8880
.SILENT: ;
default: help;   # default target

IMAGE_NAME=toolbox:latest
DOCKER_RUN = docker run --rm -v ${FOLDER}:/work -w /work --entrypoint bash -lc ${IMAGE_NAME} -c

build:
	echo "Building Dockerfile"
	docker build -t ${IMAGE_NAME} .
.PHONY: build

install: build ## First time: Build image, and install all the dependencies, including jupyter
	$(DOCKER_RUN) 'poetry install'
	echo "Changing current folder rights"
	sudo chmod -R 777 .cache
.PHONY: install

start: ## To get inside the container (can launch "poetry shell" from inside or "poetry add <package>")
	echo "Starting container ${IMAGE_NAME}"
	docker run --rm -it -v ${FOLDER}:/work -w /work -p ${PORT}:${PORT} -p 8888:8888 -e "JUPYTER_PORT=${PORT}" ${IMAGE_NAME}
.PHONY: start

notebook: ## Start the Jupyter notebook (must be run from inside the container)
	poetry run jupyter contrib nbextension install
	poetry run jupyter notebook --allow-root --ip 0.0.0.0 --port ${PORT} --no-browser --notebook-dir .
.PHONY: notebook

lab: ## Start the Jupyter lab (must be run from inside the container)
	poetry run jupyter lab --allow-root --ip 0.0.0.0 --port ${PORT} --no-browser --notebook-dir .
.PHONY: lab

help: ## Display help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.PHONY: help
