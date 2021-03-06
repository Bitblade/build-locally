#!/bin/bash
# -*-mode: Shell-script; indent-tabs-mode: nil; sh-basic-offset: 2 -*-

# Find the base directory while avoiding subtle variations in $0:
dollar0=`which $0`; PACKAGE_DIR=$(cd $(dirname $dollar0); pwd) # NEVER export PACKAGE_DIR

# Set defaults for BUILD_DIR and INSTALL_DIR environment variables and
# utility functions such as BuildDependentPackage:
. $PACKAGE_DIR/../../../support-files/build_platform_util.bash
# Define perl utility functions:
. $PACKAGE_DIR/../../../support-files/perl_util.bash

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
# Dependent packages will be installed into $INSTALL_DIR/bin so add
# that directory to the PATH:
# --------------------------------------------------------------------------------
SetupBasicEnvironment

# --------------------------------------------------------------------------------
# Build required dependent packages:
# --------------------------------------------------------------------------------
BuildDependentPackage autoconf bin/autoconf
BuildDependentPackage automake bin/automake
BuildDependentPackage libtool bin/libtool
BuildDependentPackage texinfo bin/makeinfo
BuildDependentPackage pkg-config bin/pkg-config
BuildDependentPackage glib bin/gobject-query
BuildDependentPackage libpng lib/pkgconfig/libpng\*.pc
BuildDependentPackage pixman lib/pkgconfig/pixman-\*.pc
BuildDependentPackage freetype lib/pkgconfig/freetype\*.pc

# --------------------------------------------------------------------------------
# Dependent packages will be installed into $INSTALL_DIR/bin so add
# that directory to the PATH:
# --------------------------------------------------------------------------------
SetupBasicEnvironment

# --------------------------------------------------------------------------------
# Create build directory structure:
# --------------------------------------------------------------------------------
CreateAndChdirIntoBuildDir cairo

# --------------------------------------------------------------------------------
# Check out the source into the build directory:
# --------------------------------------------------------------------------------
packageSubDir=cairo
# http://cairographics.org/download/#git
DownloadPackageFromGitRepo git://anongit.freedesktop.org/git/cairo $packageSubDir

PrintRun cd $packageSubDir

# --------------------------------------------------------------------------------
# Configure
# --------------------------------------------------------------------------------
echo "Configuring ..."
# Run autogen.sh which also generates and runs ./configure:
PrintRun ./autogen.sh --prefix="$INSTALL_DIR"
if [ ! -f ./configure ]
then
  echo "ERROR: Could not create ./configure file. autoconf must have failed."
  exit 1
fi

# --------------------------------------------------------------------------------
# Build:
# --------------------------------------------------------------------------------
echo "Building ..."
PrintRun make

# --------------------------------------------------------------------------------
# Install:
# --------------------------------------------------------------------------------
echo "Installing ..."
PrintRun make install

# --------------------------------------------------------------------------------
# Testing:
# --------------------------------------------------------------------------------
echo "Testing ..."

pcFile="$INSTALL_DIR/lib/pkgconfig/cairo.pc"
if [ ! -f "$pcFile" ]
then
  echo "ERROR: Could not find expected file at: $pcFile"
  exit 1
fi

echo "Note: All installation tests passed."
exit 0
