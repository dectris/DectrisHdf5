#
#  Dectris Ltd.
#  Neuenhoferstrasses 107, CH - 5400 Baden, Switzerland.
#  All rights reserved. Copyright(C) 2012 - 2014
#
#
cmake_minimum_required (VERSION 2.8.11)
project (dectris-hdf5)


if(NOT CMAKE_BUILD_TYPE)
  set ( CMAKE_BUILD_TYPE Release )
endif()

set (VERSION_MAJOR 1)
set (VERSION_MINOR 8)
set (VERSION_PATCH 11)
set (VERSION ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH})

option (CPP11 "Compile with c++11" ON)
if(CPP11)
    MESSAGE(STATUS "Compiling with c++11 ON")
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
else()
    MESSAGE(STATUS "Compiling with c++11 OFF")
endif()


if (APPLE)
  set (CMAKE_CXX_FLAGS_RELEASE "-O3  -mmacosx-version-min=10.7")
  set (CMAKE_EXE_LINKER_FLAGS "-O3 -mmacosx-version-min=10.7")
  set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++")
endif()







# Tell hdf5 that we are manually overriding certain settings
set(HDF5_EXTERNALLY_CONFIGURED 1)

# Avoid duplicating names of installed libraries
set(HDF5_EXTERNAL_LIB_PREFIX "dectris")

# set options for bulding hdf5
set (BUILD_SHARED_LIBS ON CACHE BOOL "Build Shared Libraries")
set (HDF5_BUILD_TOOLS ON CACHE BOOL "Build HDF5 Tools")
set (HDF5_BUILD_HL_LIB ON CACHE BOOL "Build HIGH Level HDF5 Library")
set (HDF5_BUILD_CPP_LIB ON CACHE BOOL "Build c++ API")
set (HDF5_ENABLE_Z_LIB_SUPPORT ON CACHE BOOL "Enable zlib")

if(WIN32)
    ### INSTALL ZLIB ON WINDOWS
    #
    #  Download from http://zlib.net/zlib128.zip and extract to zlib128
    #  cd zlib128
    #  mk build
    #  cd build
    #  cmake -G "MinGW Makefiles" -DCMAKE_INSTALL_PREFIX=zlib128 ..\zlib-1.2.8
    #  mingw32-make -j8
    #  mingw32-make install
    #  cp -r zlib128 C:\
    #
    #  change path variable (as administrator)
    #  $oldPath=(Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).Path
    #  $newPath=$oldPath+';C:\zlib128\bin'
    #  Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $newPath
    #
    #
    set(CMAKE_PREFIX_PATH C:/zlib128 )
endif()
# Add the sub project
add_subdirectory (hdf5-${VERSION})

set (INCLUDE_INSTALL_DIR include/  )
if (WIN32)
  set (LIB_INSTALL_DIR bin/ )
  set (STATIC_INSTALL_DIR lib/ )
  set (CMAKE_INSTALL_DIR cmake/)
else ()
  set (CMAKE_INSTALL_PREFIX "/usr/local")
  IF (CMAKE_BUILD_TYPE MATCHES Debug)
     set (CMAKE_INSTALL_DIR lib/DectrisHdf5Debug/cmake/)
  ELSE()
     set (CMAKE_INSTALL_DIR lib/DectrisHdf5/cmake/)
  ENDIF()
  set (LIB_INSTALL_DIR lib/ )
  set (STATIC_INSTALL_DIR lib/ )
endif ()

include (CMakePackageConfigHelpers)
IF (CMAKE_BUILD_TYPE MATCHES Debug)
   configure_package_config_file (cmake/DectrisHdf5DebugConfig.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/DectrisHdf5DebugConfig.cmake
                                 INSTALL_DESTINATION ${CMAKE_INSTALL_DIR}
                                 PATH_VARS INCLUDE_INSTALL_DIR LIB_INSTALL_DIR STATIC_INSTALL_DIR)
   write_basic_package_version_file (${CMAKE_CURRENT_BINARY_DIR}/DectrisHdf5DebugConfig-version.cmake
                                    VERSION ${VERSION}
                                    COMPATIBILITY ExactVersion )
   install (FILES ${CMAKE_CURRENT_BINARY_DIR}/DectrisHdf5DebugConfig.cmake ${CMAKE_CURRENT_BINARY_DIR}/DectrisHdf5DebugConfig-version.cmake
            DESTINATION ${CMAKE_INSTALL_DIR} )
ELSE()
   configure_package_config_file (cmake/DectrisHdf5Config.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/DectrisHdf5Config.cmake
                                 INSTALL_DESTINATION ${CMAKE_INSTALL_DIR}
                                 PATH_VARS INCLUDE_INSTALL_DIR LIB_INSTALL_DIR STATIC_INSTALL_DIR)
   write_basic_package_version_file (${CMAKE_CURRENT_BINARY_DIR}/DectrisHdf5Config-version.cmake
                                    VERSION ${VERSION}
                                    COMPATIBILITY ExactVersion )
   install (FILES ${CMAKE_CURRENT_BINARY_DIR}/DectrisHdf5Config.cmake ${CMAKE_CURRENT_BINARY_DIR}/DectrisHdf5Config-version.cmake
            DESTINATION ${CMAKE_INSTALL_DIR} )
ENDIF()
       
#
# Generic Package Information
#
set (CPACK_PACKAGE_VERSION            ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH})
set (CPACK_PACKAGE_VENDOR            "Dectris Ltd.")

#
# Linux
if (UNIX)
  set (CPACK_RPM_PACKAGE_ARCH  "x86_64") 
  set (CPACK_RPM_PACKAGE_ARCHITECTURE  "x86_64") 
  set (CPACK_RPM_PACKAGE_VENDOR      ${CPACK_PACKAGE_VENDOR})

  set (CPACK_PACKAGE_NAME              "dectris-hdf5")
  set (CPACK_PACKAGE_FILE_NAME         "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-$ENV{BUILD_NUMBER}.${CPACK_RPM_PACKAGE_ARCHITECTURE}")
  set (CPACK_PACKAGE_DESCRIPTION       "${CPACK_PACKAGE_NAME} build $ENV{BUILD_NUMBER}")
  set (CPACK_RPM_PACKAGE_SUMMARY       "${CPACK_PACKAGE_NAME} build $ENV{BUILD_NUMBER}")
  set (CPACK_PACKAGE_RELEASE            $ENV{BUILD_NUMBER})
  set (CPACK_RPM_PACKAGE_RELEASE        $ENV{BUILD_NUMBER})

  set (CPACK_RPM_PACKAGE_REQUIRES      "zlib")
  # This is not actually used by cmake but enlists the packages needed for building (in addition to the ones
  # listed above) but not used for running. This information is processes by the "satiate.sh" script
  set (CPACK_BUILD_RPM_PACKAGE_REQUIRES "make, zlib-devel")

  message (STATUS "> Creating RPM ${CPACK_PACKAGE_FILE_NAME}")
  set (CPACK_GENERATOR RPM)
  set (CPACK_PACKAGING_INSTALL_PREFIX  "${CMAKE_INSTALL_PREFIX}")
  set (CPACK_PACKAGE_INSTALL_PREFIX    "${CMAKE_INSTALL_PREFIX}")
  set (CPACK_PACKAGE_INSTALL_DIRECTORY "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}")

endif ()

#
# Windows
if (WIN32)
  # Only VolP is allowed to change anything in this section
  set (CPACK_PACKAGE_NAME "DectrisHdf5")
  set (CPACK_PACKAGE_INSTALL_DIRECTORY "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}")
  # Generate guid for every major release
  execute_process (COMMAND
    python -c "import uuid; print uuid.uuid5(uuid.NAMESPACE_DNS,\"DectrisHdf5-${VERSION}.dectris.com\")"
    OUTPUT_VARIABLE CPACK_WIX_UPGRADE_GUID
    OUTPUT_STRIP_TRAILING_WHITESPACE
    )
  message (STATUS "WIX Upgrade GUID ${CPACK_WIX_UPGRADE_GUID}" )
  set (CPACK_GENERATOR WIX)
endif()


include (CPack)

#
# Uninstall Target
#
configure_file(
    "cmake/cmake_uninstall.cmake.in"
    "cmake/cmake_uninstall.cmake"
    IMMEDIATE @ONLY)

add_custom_target(uninstall
    COMMAND ${CMAKE_COMMAND} -P cmake/cmake_uninstall.cmake)
