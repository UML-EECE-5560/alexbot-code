# Install process:
# - Make sure this repo is cloned on raspi image SD
# - Use raspi image to install Ubuntu on SSD
# - Use setup_install.sh to copy install script
# - Reboot and setup Ubuntu:
#   - Username: student
#   - Password: student
#   - Hostname: abot-XX
#   MAKE SURE RASPI IS LABELED WITH HOSTNAME
# - Settings -> Power -> Screen Blank -> Never
# - Run install.sh

# TODO: clean up apt installs

sudo usermod -a -G video student

sudo apt update
sudo apt upgrade

# Max USB power

sudo sed -i s/usb_max_current_enable=0/usb_max_current_enable=1 /boot/firmware/config.txt

sudo rpi-eeprom-config --edit

# Generic dependencies

sudo apt -y install vim emacs git openssh-server catkin-tools

# ROS install

sudo apt -y install software-properties-common
sudo add-apt-repository universe

sudo apt update && sudo apt install curl -y
export ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F\" '{print $4}')
curl -L -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo ${UBUNTU_CODENAME:-${VERSION_CODENAME}})_all.deb"
sudo dpkg -i /tmp/ros2-apt-source.deb

sudo apt update && sudo apt -y install ros-dev-tools
sudo apt -y install ros-jazzy-desktop ros-jazzy-hardware-interface

sudo rosdep init
rosdep update

# Build libcamera - not needed as it is done in camera_ros

sudo apt install -y python-pip git python3-jinja2
sudo apt install -y libboost-dev
sudo apt install -y libgnutls28-dev openssl libtiff-dev pybind11-dev
sudo apt install -y qtbase5-dev libqt5core5a libqt5widgets
sudo apt install -y meson cmake
sudo apt install -y python3-yaml python3-ply
sudo apt install -y libglib2.0-dev libgstreamer-plugins-base1.0-dev

# git clone https://github.com/raspberrypi/libcamera.git
# cd libcamera
# meson setup build --buildtype=release -Dpipelines=rpi/vc4,rpi/pisp -Dipas=rpi/vc4,rpi/pisp -Dv4l2=true -Dgstreamer=enabled -Dtest=false -Dlc-compliance=disabled -Dcam=disabled -Dqcam=disabled -Ddocumentation=disabled -Dpycamera=enabled
# ninja -C build install

# cd ..

# Build rpi-cam utils for debugging

sudo apt -y install clang meson ninja-build pkg-config libyaml-dev python3-yaml python3-ply python3-jinja2 openssl
sudo apt -y install libdw-dev libunwind-dev libudev-dev libudev-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libpython3-dev pybind11-dev libevent-dev libtiff-dev qt6-base-dev qt6-tools-dev-tools liblttng-ust-dev python3-jinja2 lttng-tools libexif-dev libjpeg-dev pybind11-dev libevent-dev libgtest-dev abi-compliance-checker

# git clone https://github.com/raspberrypi/libcamera.git
# cd libcamera
# meson setup build --buildtype=release -Dpipelines=rpi/vc4,rpi/pisp -Dipas=rpi/vc4,rpi/pisp -Dv4l2=true -Dgstreamer=enabled -Dtest=false -Dlc-compliance=disabled -Dcam=disabled -Dqcam=disabled -Ddocumentation=disabled -Dpycamera=enabled
# ninja -C build install
# sudo ninja -C build install

# cd 
# git clone https://github.com/raspberrypi/rpicam-apps.git
# cd rpicam-apps/
sudo apt -y install cmake libboost-program-options-dev libdrm-dev libexif-dev
sudo apt -y install ffmpeg libavcodec-extra libavcodec-dev libavdevice-dev libpng-dev libpng-tools libepoxy-dev 
sudo apt -y install qt5-qmake qtmultimedia5-dev
# meson setup build -Denable_libav=disabled -Denable_drm=enabled -Denable_egl=enabled -Denable_qt=enabled -Denable_opencv=disabled -Denable_tflite=disabled -Denable_hailo=disabled 
# meson compile -C build
# sudo meson install -C build



# create workspace
mkdir -p ~/camera_ws/src
cd ~/camera_ws/src

# check out libcamera
sudo apt -y install python3-colcon-meson
# Option A: official upstream
# git clone https://git.libcamera.org/libcamera/libcamera.git
# Option B: raspberrypi fork with support for newer camera modules
git clone https://github.com/raspberrypi/libcamera.git

# check out this camera_ros repository
git clone https://github.com/christianrauch/camera_ros.git

# resolve binary dependencies and build workspace
source /opt/ros/jazzy/setup.bash
cd ~/camera_ws/
rosdep install -y --from-paths src --ignore-src --rosdistro $ROS_DISTRO --skip-keys=libcamera
colcon build --event-handlers=console_direct+

# setup ros workspaces
mkdir -p ~/class_ws/src
cd ~/class_ws/src
git clone https://github.com/UML-EECE-5560/alexbot-code.git
git clone https://github.com/Slamtec/sllidar_ros2.git
cd ..
source ~/camera_ws/install/setup.bash
colcon build --symnlink-install
source ~/class_ws/install/setup.bash

mkdir -p ~/ros_ws/src
cd ~/ros_ws
colcon build --symnlink-install
source ~/ros_ws/install/setup.bash

