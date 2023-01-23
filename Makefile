ROS_DISTRO = humble
OWNER = mxrobotics
PREFIX = mx
 

PERSISTENT_GZ  = ${HOME}/tmp/${OWNER}/${ROS_DISTRO}-gazebo
PROJECT_DIR = $(shell cd ..; pwd)
PROJECT_DIR_NAME = MX_DIR # define a project name enviroment variable
HOSTNAME := $(shell hostname)
RUN = deploy
	
	
all: help

help:
	@echo ""
	@echo "   Help Menu"
	@echo ""
	@echo "   make build                      - build all images"
	@echo "   make login USER=username        - authenticate container Registry"
	@echo "   make pull                       - pull all images"
	@echo "   make push                       - push all images"
	@echo "   make clean                      - remove all images"
	@echo "   make run         RUN=base       - runs: base | deploy"
	@echo "   make run-local   RUN=deploy     - runs a container and mounts ${PROJECT_DIR}"
	@echo ""

login:
	@docker login -u ${USER}

build-base:
	@docker build --rm -t ${OWNER}/${PREFIX}-${ROS_DISTRO}-base \
															--build-arg OWNER=osrf \
															--build-arg BASE_CONTAINER=ros:${ROS_DISTRO}-desktop \
													        --build-arg INSTALL_TERMINAL_TOOLS=true \
													        --build-arg INSTALL_STAGE=true \
													        --build-arg INSTALL_XFCE=true \
													        --build-arg INSTALL_VSCODE=true \
													        --build-arg INSTALL_GAZEBO=true \
													        --build-arg INSTALL_VNC=true \
															--build-arg INSTALL_NAV2=true \
	                                                        .

build: build-base

push:
	@docker push ${OWNER}/${PREFIX}-${ROS_DISTRO}-base

pull:
	@docker pull ${OWNER}/${PREFIX}-${ROS_DISTRO}-base

clean:
	@docker rmi -f ${OWNER}/${PREFIX}-${ROS_DISTRO}-base

remove-images-none:
	@docker rmi $(shell docker images -f "dangling=true" -q)

remove-container-stoped:
	@docker rm $(shell docker ps --filter status=exited -q)

run:
	@docker run -ti --rm --privileged --network="host" --env="DISPLAY" --add-host "${HOSTNAME}-${RUN}:127.0.0.1" --hostname ${HOSTNAME}-${RUN} --name ${HOSTNAME}-${RUN} \
		-v ${HOME}/.sdformat:/home/robot/.sdformat \
		-v ${HOME}/.ignition:/home/robot/.ignition \
		-v ${HOME}/.gazebo:/home/robot/.gazebo \
		-v /tmp/runtime-robot:/tmp/runtime-robot \
		-v /dev/shm:/dev/shm \
	${OWNER}/${PREFIX}-${ROS_DISTRO}-${RUN}

run-local:
	@docker run -ti --rm --privileged --network="host" --env="DISPLAY" --add-host "${HOSTNAME}-${RUN}:127.0.0.1" --hostname ${HOSTNAME}-${RUN} --name ${HOSTNAME}-${RUN} \
		-v ${HOME}/.sdformat:/home/robot/.sdformat \
		-v ${HOME}/.ignition:/home/robot/.ignition \
		-v ${HOME}/.gazebo:/home/robot/.gazebo \
		-v /tmp/runtime-robot:/tmp/runtime-robot \
		-v /dev/shm:/dev/shm \
		-v ${PROJECT_DIR}:/opt/greenhive \
	${OWNER}/${PREFIX}-${ROS_DISTRO}-${RUN}