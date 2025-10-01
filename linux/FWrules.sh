# lab type shit

if [[ $EUID -ne 0 ]]; then
   echo "this script must be run as root" 
   exit 1
fi

# prompt user for red and blue interface names
read -p "Enter the name of the red interface (default: enp2s0): " red
read -p "Enter the name of the blue interface (default: enp1s0): " blue
red=${red:-enp2s0}
blue=${blue:-enp1s0}

