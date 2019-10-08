#!/bin/bash

# ADAPT TO YOUR SYSTEM CONFIGURATION!
STEAM_PATH=~/.steam/steam
STEAMVR_PATH=$STEAM_PATH/steamapps/common/SteamVR

if ((1<<32)); then
  ARCH_TARGET=linux64
else
  ARCH_TARGET=linux32
fi

# Get OpenVR files if not present
if [[ ! -d api/${ARCH_TARGET} ]]
then
  mkdir -p api/${ARCH_TARGET}
  cd api/${ARCH_TARGET}
  rm ./{libopenvr_api.so,libopenvr_api.so.dbg}
  wget https://raw.githubusercontent.com/ValveSoftware/openvr/master/bin/${ARCH_TARGET}/libopenvr_api.so
  wget https://raw.githubusercontent.com/ValveSoftware/openvr/master/bin/${ARCH_TARGET}/libopenvr_api.so.dbg
  cd ../..
fi
if [[ ! -e driver_sample/openvr_driver.h ]]
then
  cd driver_sample
  rm ./{driverlog.cpp,driverlog.h,openvr_driver.h}
  wget https://raw.githubusercontent.com/ValveSoftware/openvr/master/headers/openvr_driver.h
  wget https://raw.githubusercontent.com/ValveSoftware/openvr/master/samples/driver_sample/driverlog.cpp
  wget https://raw.githubusercontent.com/ValveSoftware/openvr/master/samples/driver_sample/driverlog.h
  cd ..
fi

# Compile
cmake . -DCMAKE_PREFIX_PATH=/opt/Qt/5.6/gcc_64/lib/cmake -DCMAKE_BUILD_TYPE=Release
make -j4

# Install
rm -rf ~/$STEAMVR_PATH/drivers/sample
cp -r ./bin/drivers/sample $STEAMVR_PATH/drivers/sample
mkdir -p $STEAMVR_PATH/drivers/sample/bin/${ARCH_TARGET}
cp -r ./bin/${ARCH_TARGET} $STEAMVR_PATH/drivers/sample/bin/

# WARNING: This might be wrong on some systems
# However the vrpathreg.sh script has an incorrect path reference on my system.
cd ${STEAMVR_PATH}/bin/linux64
  LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(pwd) ./vrpathreg adddriver "/sample"
cd -

# Cleanup
rm CMakeCache.txt cmake_install.cmake Makefile
rm driver_sample/cmake_install.cmake driver_sample/Makefile 
rm -rf CMakeFiles
rm -rf driver_sample/CMakeFiles driver_sample/driver_sample_autogen
rm -rf ./bin/${ARCH_TARGET}

# Cleanup steam logs
rm -f $STEAM_PATH/logs/*
