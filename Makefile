OWNER = mxrobotics
PREFIX = mx

ROS_DISTRO = humble
PROJECT_DIR = $(shell cd ..; pwd)
HOSTNAME := $(shell hostname)
RUN = develop
	
	
all: help

help:
	@echo ""
	@echo "   Help Menu"
	@echo ""
	@echo "   make build                      - build all images"
	@echo "   make build-base                 - build only the base ${OWNER}/${PREFIX}-${ROS_DISTRO}-base"
	@echo "   make build-deploy               - build only the base ${OWNER}/${PREFIX}-${ROS_DISTRO}-deploy"
	@echo "   make build-develop              - build only the base ${OWNER}/${PREFIX}-${ROS_DISTRO}-develop"
	@echo "   make login USER=username        - authenticate container Registry"
	@echo "   make pull                       - pull all images exept develop"
	@echo "   make push                       - push all images exept develop"
	@echo "   make rm-stopped                 - remove all stopped containers"
	@echo "   make rmi                        - remove all images"
	@echo "   make rmi-none                   - remove all images with <nones>"
	@echo "   make run         RUN=develop    - runs: base|develop|deploy"
	@echo "   make run-local   RUN=deploy     - runs a container and mounts ${PROJECT_DIR}"
	@echo ""

login:
	@docker login -u ${USER}

build: build-base build-develop build-deploy

push: push-base push-deploy

pull: push-pull push-pull

docker_base:
	git clone -b master git@github.com:mx-robotics/docker_base.git

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
															-f ./Dockerfile-base .

push-base:
	@docker push ${OWNER}/${PREFIX}-${ROS_DISTRO}-base

pull-base:
	@docker pull ${OWNER}/${PREFIX}-${ROS_DISTRO}-base

build-develop:
	@docker build --rm -t ${OWNER}/${PREFIX}-${ROS_DISTRO}-develop \
													        --build-arg OWNER=${OWNER} \
													        --build-arg PROJECT_DIR=${PROJECT_DIR} \
													   		--build-arg PROJECT_DIR_NAME=${PROJECT_DIR_NAME} \
													  		--build-arg BASE_CONTAINER=${PREFIX}-${ROS_DISTRO}-base \
															-f Dockerfile-develop  ../
															
build-deploy:
	@docker build --rm -t ${OWNER}/${PREFIX}-${ROS_DISTRO}-deploy \
													        --build-arg OWNER=${OWNER} \
													        --build-arg PROJECT_DIR=${PROJECT_DIR} \
													   		--build-arg PROJECT_DIR_NAME=${PROJECT_DIR_NAME} \
													  		--build-arg BASE_CONTAINER=${PREFIX}-${ROS_DISTRO}-base \
													  		--build-arg SOURCE_CONTAINER=${OWNER}/${PREFIX}-${ROS_DISTRO}-develop \
															-f Dockerfile-deploy  ../

push-deploy:
	@docker push ${OWNER}/${PREFIX}-${ROS_DISTRO}-base

pull-deploy:
	@docker pull ${OWNER}/${PREFIX}-${ROS_DISTRO}-base

rmi:
	@docker rmi -f ${OWNER}/${PREFIX}-${ROS_DISTRO}-base
	@docker rmi -f ${OWNER}/${PREFIX}-${ROS_DISTRO}-develop
	@docker rmi -f ${OWNER}/${PREFIX}-${ROS_DISTRO}-deploy

rmi-none:
	@docker rmi $(shell docker images -f "dangling=true" -q)

rm-stopped:
	@docker rm $(shell docker ps --filter status=exited -q)

run:
	@docker run -ti --rm --privileged --network="host" --env="DISPLAY" \
	    --add-host "${PREFIX}-${RUN}:127.0.0.1"  \
	    --hostname ${PREFIX}-${RUN}  \
		--name ${PREFIX}-${RUN} \
		-v ${HOME}/.sdformat:/home/robot/.sdformat \
		-v ${HOME}/.ignition:/home/robot/.ignition \
		-v ${HOME}/.gazebo:/home/robot/.gazebo \
		-v /tmp/runtime-robot:/tmp/runtime-robot \
		-v /dev/shm:/dev/shm \
	${OWNER}/${PREFIX}-${ROS_DISTRO}-${RUN}

run-local:
	@docker run -ti --rm --privileged --network="host" --env="DISPLAY" \
	    --add-host "${PREFIX}-${RUN}:127.0.0.1"  \
	    --hostname ${PREFIX}-${RUN}  \
		--name ${PREFIX}-${RUN} \
		-v ${HOME}/.sdformat:/home/robot/.sdformat \
		-v ${HOME}/.ignition:/home/robot/.ignition \
		-v ${HOME}/.gazebo:/home/robot/.gazebo \
		-v /tmp/runtime-robot:/tmp/runtime-robot \
		-v /dev/shm:/dev/shm \
		-v ${PROJECT_DIR}:${PROJECT_DIR}  \
	${OWNER}/${PREFIX}-${ROS_DISTRO}-${RUN}

create:
	@docker create --privileged --network="host" --env="DISPLAY" \
	    --add-host "${PREFIX}-${RUN}:127.0.0.1"  \
	    --hostname ${PREFIX}-${RUN}  \
		--name ${PREFIX}-${RUN} \
		--entrypoint /entrypoint-vnc.sh  \
		-v /dev/shm:/dev/shm \
		-v ${PROJECT_DIR}:${PROJECT_DIR}  \
	${OWNER}/${PREFIX}-${ROS_DISTRO}-${RUN}

start:
	@docker start ${PREFIX}-${RUN}

stop:
	@docker stop ${PREFIX}-${RUN}

rm:
	@docker rm ${PREFIX}-${RUN}
