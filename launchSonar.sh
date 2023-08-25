#!/bin/bash
#==
#   NOTE      - launchSonar.sh
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

function usage_print()
{
  echo "Usage: ./launchSonar.sh [[-i ip-address] | [-h]]"
  echo "Launch ROS Image Sonar"
  echo "Launch 169.254.11.203 as default ROS ip-address; Use [-i/--ip] to override"
  echo "-i | --ip <ip-address>  ROS Sonar IP address"
  echo "                        Blank this would set ip-address as:"
  echo "                         169.254.11.203"
  echo "-h | --help  This message"
}

function launch_ros()
{
  export ROS_MASTER_URI=http://localhost:11311
  export ROS_IP=${ip_address}
  export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
  roscore &
  sleep 10
}

function launch_sonar()
{
  . ~/catkin_ws/devel/setup.bash
  rospack profile
  rospack find sonar_oculus

  roslaunch sonar_oculus sonar_oculus.launch &
}




#==
#   Starting codes in blew
#/

if [[ $EUID -eq 0 ]]; then
  error_exit "This script must be run as USER!"
fi


if [[ "$1" != "" ]]; then
  case $1 in
    -i | --ip )     shift; ip_address=$1;;
    -h | --help )   usage_print; exit;;
    * )             usage_print; exit 1;;
  esac
else
  ip_address=169.254.11.203
fi

script_print_notify "ROS IP to launch: "${ip_address}"\n"


# Launch ROS
script_print "Launching ROS...\n"
launch_ros || error_exit "Launch ROS failed."
script_print_notify "Launch ROS done.\n"

# Launch Sonar
script_print "Launching sonar...\n"
launch_sonar || error_exit "Launch sonar failed."
script_print_notify "Launch sonar done.\n"

script_print_notify "All successfully done.\n\n"
