#!/bin/bash
# -*-mode: Shell-script; indent-tabs-mode: nil; sh-basic-offset: 2 -*-

# Find the base directory while avoiding subtle variations in $0:
dollar0=`which $0`; PACKAGE_DIR=$(cd $(dirname $dollar0); pwd) # NEVER export PACKAGE_DIR

# Set defaults for BUILD_DIR and INSTALL_DIR environment variables and
# utility functions such as BuildDependentPackage:
. $PACKAGE_DIR/../../../support-files/build_platform_util.bash

usage () {
  cat <<EOF
USAGE: $0 ... options ...

Options are:

[ -builddir BUILD_DIR ]

  Override the BUILD_DIR default, which is $BUILD_DIR.

[ -installdir INSTALL_DIR ]

  Override the INSTALL_DIR default, which is $INSTALL_DIR.

EOF
}

while [ $# -gt 0 ]
do
  if [ "$1" = "-builddir" ]
  then
    BUILDDIR="$2"
    shift
  elif [ "$1" = "-installdir" ]
  then
    INSTALLDIR="$2"
    shift
  elif [ "$1" = "-h" ]
  then
    usage
    exit 0
  else
    echo "Undefined parameter $1"
    exit 1
  fi
  shift
done


# --------------------------------------------------------------------------------
# Create build directory structure:
# --------------------------------------------------------------------------------
CreateAndChdirIntoBuildDir freecad


# http://freecadweb.org/wiki/index.php?title=CompileOnUnix#Compile_FreeCAD

# This will work only for Debian systems. Later on we can rework this to build completely from source:

# TODO: See if we can build all of these from source, or use my Debian
# source package routines as done in ../../sqlite3/linux/build.bash

tmpscript=$(pwd)/tmpscript.$$
trap "rm -f $tmpscript" 0 # arrange to remove $tmpscript upon failure

set -x

cat > $tmpscript <<EOF
set -x -e

# --------------------------------------------------------------------------------
# apt-get update <-- It is not certain if this helps with missing packages
# --------------------------------------------------------------------------------

apt-get install -y build-essential
apt-get install -y cmake
apt-get install -y python
apt-get install -y python-matplotlib
apt-get install -y libtool

# --------------------------------------------------------------------------------
# Now getting this error:
# Building dependency tree       
# Reading state information... Done
# E: Unable to locate package libcoin80-dev
# + rm -f /home/brentg/build/Debian.7.x86_64/freecad/tmpscript.4338
# + exit -1
# 
# I cannot find libcoin80-dev. Try apt-get update. No that does not work.
#
# See if using python-pivy http://forum.freecadweb.org/viewtopic.php?f=4&t=5096#p40018 will work around it.
# It might: python-pivy depends upon libcoin60. Also libsoqt4-dev depends upon libcoin60-dev.
# apt-get install -y libcoin80-dev <-- this does not work on Wheezy for some reason.
apt-get install -y python-pivy  # <-- this does work and is dependent upon libcoin60
# But that leaves us with the outstanding question: What are we missing
# out on if we install libcoin60 and not libcoin80? Is libcoin80
# "better"?
# --------------------------------------------------------------------------------

apt-get install -y libsoqt4-dev
apt-get install -y libxerces-c-dev
apt-get install -y libboost-dev
apt-get install -y libboost-filesystem-dev
apt-get install -y libboost-regex-dev
apt-get install -y libboost-program-options-dev 
apt-get install -y libboost-signals-dev
apt-get install -y libboost-thread-dev
apt-get install -y libqt4-dev
apt-get install -y libqt4-opengl-dev
apt-get install -y qt4-dev-tools
apt-get install -y python-dev
apt-get install -y python-pyside

# --------------------------------------------------------------------------------
# apt-get install -y liboce*-dev (opencascade community edition) <-- huh? They didn't spell out which ones are in the "*"???
apt-get install -y liboce-foundation-dev
apt-get install -y liboce-modeling-dev
apt-get install -y liboce-ocaf-dev
# apt-get install -y liboce-ocaf-lite-dev # <-- huh? What is this lite thing huh whuh?
apt-get install -y liboce-visualization-dev
# --------------------------------------------------------------------------------

apt-get install -y oce-draw
apt-get install -y gfortran
apt-get install -y libeigen3-dev
apt-get install -y libqtwebkit-dev
apt-get install -y libshiboken-dev
apt-get install -y libpyside-dev
apt-get install -y libode-dev
apt-get install -y swig
apt-get install -y libzipios++-dev
apt-get install -y libfreetype6
apt-get install -y libfreetype6-dev

# --------------------------------------------------------------------------------
# Extra packages:
apt-get install -y libsimage-dev                 # <-- (to make Coin to support additional image file formats)
#apt-get install -y checkinstall                 # <-- (to register your installed files into your system's package manager, so yo can easily uninstall later)
#apt-get install -y python-pivy                  # <-- (needed for the 2D Drafting module) (ALREADY INSTALLED ABOVE)
apt-get install -y python-qt4                    # <-- (needed for the 2D Drafting module)
apt-get install -y doxygen libcoin60-doc         # <-- (if you intend to generate source code documentation)
#apt-get install -y libspnav-dev                 # <-- (for 3Dconnexion devices support like the Space Navigator or Space Pilot) (I DON'T HAVE SUCH A DEVICE SO EXCLUDING THIS)
# --------------------------------------------------------------------------------


EOF

chmod a+x $tmpscript
sudo sh -c $tmpscript

# --------------------------------------------------------------------------------
# Download the source for freecad into the build directory:
# --------------------------------------------------------------------------------
echo "Downloading ..."
# http://freecadweb.org/wiki/index.php?title=CompileOnUnix#Getting_the_source
git clone git://git.code.sf.net/p/free-cad/code free-cad-code

# --------------------------------------------------------------------------------
# Build:
# --------------------------------------------------------------------------------
echo "Building ..."


# --------------------------------------------------------------------------------
# Install:
# --------------------------------------------------------------------------------
echo "Installing ..."

