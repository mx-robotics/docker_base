# docker_base
This repo hold docker files to crate a docker container with ROS2 (humble) and supports a multiple options on the build.

* XFCE Desktop 
* TURBO VNC Server
* VSCode
* ROS NAV2 
* GAZEBO

For details checkout the Makefile

## make
A make file is used to create and run the container

## Demo

### non-persistent container
```
git clone -b master https://github.com/mx-robotics/docker_base.git
cd docker_base
make build
# make pull
make run RUN=base
```

### persistent container with vnc
```
git clone -b master https://github.com/mx-robotics/docker_base.git
cd docker_base
make build
# make pull
make create RUN=base
make start RUN=base
---> connect with an VNCClient https://sourceforge.net/projects/turbovnc/files/
```
