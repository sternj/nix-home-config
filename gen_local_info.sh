#!/bin/bash

# This script generates a local_info.nix containing two variables, "userName" with the 
# current username and "homeDirectory" containing the home directory path.

# Get the current username
userName=$(whoami)
# Get the home directory path
homeDirectory=$(eval echo ~$userName)
# Create the local_info.nix file with the variables
cat <<EOF > local_info.nix
{
  userName = "$userName";
  homeDirectory = "$homeDirectory";
} 
EOF