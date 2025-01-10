FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Kiev
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt update && apt install -y lsb-release curl gnupg

# ROS
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -
RUN apt update && apt install -y \
    ros-noetic-ros-base \
    ros-noetic-mavros \
    ros-noetic-video-stream-opencv

RUN apt update && apt install -y git wget autoconf automake nano \
	python3-dev python3-pip python3-scipy python3-matplotlib \
	ipython3 python3-wxgtk4.0 python3-tk python3-igraph python3-pyx \
	libeigen3-dev libboost-all-dev libsuitesparse-dev doxygen \
	libopencv-dev libpoco-dev libtbb-dev libblas-dev liblapack-dev libv4l-dev

RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mavlink/mavros/master/mavros/scripts/install_geographiclib_datasets.sh)"

# Create the workspace and build kalibr in it
RUN apt update && apt install -y python3-catkin-tools python3-osrf-pycommon

ENV WORKSPACE=/catkin_ws
RUN apt install -y ros-noetic-catkin
# RUN mkdir -p $WORKSPACE/src && \
# 	cd $WORKSPACE && \
# 	catkin init && \
# 	catkin config --extend /opt/ros/noetic && \
# 	catkin config --cmake-args -DCMAKE_BUILD_TYPE=Release

RUN apt install -y tmux nano gedit htop

RUN apt-get install -y ros-noetic-rqt-image-view
# ffmpeg
RUN apt-get install -y ffmpeg

# Update shared library cache
RUN ldconfig

# Verify FFmpeg installation
RUN ffmpeg -version
# libcamera
RUN apt update
RUN apt install -y qtbase5-dev libqt5core5a libqt5gui5 libqt5widgets5
RUN apt install -y libavcodec-dev libavdevice-dev libavformat-dev libswresample-dev
RUN apt install -y libboost-dev

RUN apt install -y libgnutls28-dev openssl libtiff5-dev pybind11-dev

RUN apt install -y qtbase5-dev libqt5core5a libqt5gui5 libqt5widgets5

RUN apt update

RUN apt update && apt install -y python3-yaml python3-ply
RUN apt install -y libglib2.0-dev libgstreamer-plugins-base1.0-dev
RUN apt install -y gstreamer1.0-tools gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly
    
RUN apt-get install -y ninja-build

# rpicam-apps or older libcamera-apps
RUN apt install -y cmake libboost-program-options-dev libdrm-dev libexif-dev
RUN apt-get install -y libepoxy-dev linux-libc-dev

# ROS
RUN apt update && apt install -y \
    ros-noetic-tf \
    ros-noetic-rviz \
    ros-noetic-vision-msgs \
    ros-noetic-image-transport-plugins \
    ros-noetic-image-transport \
    ros-noetic-cv-bridge

# CERES installation
WORKDIR /root

# Install basic dependencies
RUN apt-get update && apt-get install -y \
    libgoogle-glog-dev \
    libgflags-dev \
    libatlas-base-dev \
    libeigen3-dev \
    cmake \
    libgtest-dev \
    libgmock-dev

# Clone Ceres
RUN wget http://ceres-solver.org/ceres-solver-1.12.0.tar.gz && \
    tar zxf ceres-solver-1.12.0.tar.gz

# Build and install Ceres
WORKDIR /root/ceres-solver-1.12.0
RUN mkdir build && \
    cd build && \
    cmake .. -DBUILD_TESTING=OFF \
             -DBUILD_EXAMPLES=OFF \
             -DCMAKE_INSTALL_PREFIX=/usr/local && \
    make -j4 && \
    make install && \
    ldconfig

# Create symbolic links for Ceres headers
RUN ln -s /usr/local/include/ceres /usr/include/ceres

# Clean up
RUN rm -rf /root/ceres-solver-1.12.0*

RUN apt-get install -y python3-catkin-tools python3-osrf-pycommon
RUN apt-get install -y cmake libgoogle-glog-dev libgflags-dev libatlas-base-dev libeigen3-dev libsuitesparse-dev libceres-dev
ENV WORKSPACE=/catkin_ws
WORKDIR /catkin_ws
RUN mkdir -p $WORKSPACE/src
RUN ln -s /workspace/research-odometry/open_vins /catkin_ws/src/open_vins