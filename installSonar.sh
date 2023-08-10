#!/bin/bash
#==
#   NOTE      - installSonar.sh
#   Author    - Aru
#
#   Created   - 2023.08.10
#   Github    - https://github.com/aruyu
#   Contact   - vine9151@gmail.com
#/



T_CO_RED='\e[1;31m'
T_CO_YELLOW='\e[1;33m'
T_CO_GREEN='\e[1;32m'
T_CO_BLUE='\e[1;34m'
T_CO_GRAY='\e[1;30m'
T_CO_NC='\e[0m'

CURRENT_PROGRESS=0

function script_print()
{
  echo -ne "$T_CO_BLUE[SCRIPT]$T_CO_NC$1"
}

function script_print_notify()
{
  echo -ne "$T_CO_BLUE[SCRIPT]$T_CO_NC$T_CO_GREEN-Notify- $1$T_CO_NC"
}

function script_print_error()
{
  echo -ne "$T_CO_BLUE[SCRIPT]$T_CO_NC$T_CO_RED-Error- $1$T_CO_NC"
}

function error_exit()
{
  script_print_error "$1\n\n"
  exit 1
}

function install_jetpack()
{
  sudo apt-get update -y
  sudo apt-get install nvidia-jetpack -y
}

function install_jetson_stats()
{
  #sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1
  sudo apt-get install libpython3-dev python3-numpy -y
  sudo apt-get install python3-pip -y
  sudo -H pip3 install -U jetson-stats
  #jtop
}

function isntall_jetson_fanctl()
{
  sudo apt-get install python3-dev -y
  git clone https://github.com/Pyrestone/jetson-fan-ctl.git
  sudo ~/jetson-fan-ctl/install.sh
  rm -rf jetson-fan-ctl
}

function install_ros()
{
  while true; do
    read -p "Enter what you want to install (Melodic, Noetic): " SELECTION
    case ${SELECTION} in
      [Mm][Ee][Ll][Oo][Dd][Ii][Cc] )    CURRENT_JOB=Melodic; break;;
      [Nn][Oo][Ee][Tt][Ii][Cc] )        CURRENT_JOB=Noetic; break;;
      * )                               echo "Wrong answer.";;
    esac
  done

  if [[ ${CURRENT_JOB} = "Melodic" ]]; then
    git clone https://github.com/jetsonhacks/installROSXavier
    ~/installROSXavier/installROS.sh -p ros-melodic-desktop-full
    ~/installROSXavier/setupCatkinWorkspace.sh

  elif [[ ${CURRENT_JOB} = "Noetic" ]]; then
    git clone https://github.com/aruyu/installROSXavier.git
    ~/installROSXavier/installROS.sh -p ros-noetic-desktop-full
    ~/installROSXavier/setupCatkinWorkspace.sh
  fi
}

function isntall_sonar()
{
  source ~/.bashrc
  git clone https://github.com/RobustFieldAutonomyLab/bluerov.git ~/catkin_ws/src/bluerov
  sudo apt-get install python3-dev -y
  sudo apt install python3-scipy -y
  sudo apt-get install python3-catkin-tools -y
  sudo -H pip3 install -U rospkg catkin_pkg
  cd ~/catkin_ws
  rm -r build/ devel/
  catkin build sonar_oculus || script_print_error "Sonar installation failed."

  if [[ ${CURRENT_JOB} = "Noetic" ]]; then
    sed -i '/QtCore.QByteArray/s/)",$/",/g' ~/catkin_ws/src/bluerov/sonar_oculus/launch/sonar_oculus.perspective
    sed -i 's/QtCore.QByteArray(/b/g' ~/catkin_ws/src/bluerov/sonar_oculus/launch/sonar_oculus.perspective
  fi
}




#==
#   Starting codes in blew
#/

if [[ $EUID -eq 0 ]]; then
  error_exit "This script must be run as USER!"
fi


cd $HOME

# Install Jetpack
script_print "Installing Jetpack...\n"
install_jetpack || script_print_error "Jetpack installation failed."
script_print_notify "Jetpack installation done.\n"

# Install jetson-stats
script_print "Installing jetson-stats...\n"
install_jetson_stats || script_print_error "jetson-stats installation failed."
script_print_notify "jetson-stats installation done.\n"

# Install jetson-fan-ctl
script_print "Installing jetson-fan-ctl...\n"
isntall_jetson_fanctl || script_print_error "jetson-fan-ctl installation failed."
script_print_notify "jetson-fan-ctl installation done.\n"

# Install ROS
script_print "Installing ROS...\n"
install_ros || script_print_error "ROS installation failed."
script_print_notify "ROS installation done.\n"

# Install Sonar
script_print "Installing Sonar...\n"
isntall_sonar || script_print_error "Sonar installation failed."
script_print_notify "Sonar installation done.\n"

jetson_release -v
script_print_notify "Reboot needed.\n"
script_print_notify "All successfully done.\n\n"
