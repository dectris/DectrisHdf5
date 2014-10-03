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

# Tell hdf5 that we are manually overriding certain settings
set(HDF5_EXTERNALLY_CONFIGURED 1)

# Avoid duplicating names of installed libraries
set(HDF5_EXTERNAL_LIB_PREFIX "dectris")

# set options for bulding hdf5
set (BUILD_SHARED_LIBS ON CACHE BOOL "Build Shared Libraries")
set (HDF5_BUILD_TOOLS ON CACHE BOOL "Build HDF5 Tools")
set (HDF5_BUILD_HL_LIB ON CACHE BOOL "Build HIGH Level HDF5 Library")

# Add the sub project
add_subdirectory (hdf5-${VERSION})

set (INCLUDE_INSTALL_DIR include/  )
if (WIN32)
  set (LIB_INSTALL_DIR bin/ )
  set (STATIC_INSTALL_DIR lib/ )
  set (CMAKE_INSTALL_DIR cmake/)
else ()
  set (CMAKE_INSTALL_PREFIX "/usr/local")
  set (CMAKE_INSTALL_DIR lib/DectrisHdf5/cmake/)
  set (LIB_INSTALL_DIR lib/ )
  set (STATIC_INSTALL_DIR lib/ )
endif ()


include (CMakePackageConfigHelpers)
configure_package_config_file (cmake/DectrisHdf5Config.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/DectrisHdf5Config.cmake
                               INSTALL_DESTINATION ${CMAKE_INSTALL_DIR}
                               PATH_VARS INCLUDE_INSTALL_DIR LIB_INSTALL_DIR STATIC_INSTALL_DIR)
write_basic_package_version_file (${CMAKE_CURRENT_BINARY_DIR}/DectrisHdf5Config-version.cmake
                                  VERSION ${VERSION}
                                  COMPATIBILITY ExactVersion )
install (FILES ${CMAKE_CURRENT_BINARY_DIR}/DectrisHdf5Config.cmake ${CMAKE_CURRENT_BINARY_DIR}/DectrisHdf5Config-version.cmake
         DESTINATION ${CMAKE_INSTALL_DIR} )
       
#
# Generic Package Information
#
set (CPACK_PACKAGE_VERSION            ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH})
set (CPACK_PACKAGE_VENDOR            "Dectris Ltd.")
set (CPACK_RPM_PACKAGE_VENDOR         ${CPACK_PACKAGE_VENDOR})

#
# Linux
if (UNIX)
  set (CPACK_RPM_PACKAGE_ARCH  "x86_64") 

  set (CPACK_PACKAGE_NAME              "dectris-hdf5")
  set (CPACK_PACKAGE_FILE_NAME         "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}_$ENV{BUILD_NUMBER}.{dist}-$ENV{COMPILER_NAME}-${CMAKE_CXX_COMPILER_VERSION}")
  set (CPACK_PACKAGE_DESCRIPTION       "${CPACK_PACKAGE_NAME} build $ENV{BUILD_NUMBER}")
  set (CPACK_RPM_PACKAGE_SUMMARY       "${CPACK_PACKAGE_NAME} build $ENV{BUILD_NUMBER}")
  set (CPACK_PACKAGE_RELEASE            $ENV{BUILD_NUMBER})
  set (CPACK_RPM_PACKAGE_RELEASE        $ENV{BUILD_NUMBER})

  set (CPACK_RPM_PACKAGE_REQUIRES      "dectris-h5py")

  message (STATUS "> Creating RPM ${CPACK_PACKAGE_FILE_NAME}")
  set (CPACK_GENERATOR RPM)
endif ()

#
# Windows
if (WIN32)
  set (CPACK_PACKAGE_NAME "DectrisHdf5")

  # Generate guid for every major release
  execute_process (COMMAND
    python -c "import uuid; print uuid.uuid5(uuid.NAMESPACE_DNS,\"DectrisHdf5-${VERSION}.dectris.com\")"
    OUTPUT_VARIABLE CPACK_WIX_UPGRADE_GUID
    OUTPUT_STRIP_TRAILING_WHITESPACE
    )
  message (STATUS "WIX Upgrade GUID ${CPACK_WIX_UPGRADE_GUID}" )
  set (CPACK_GENERATOR WIX)
endif()


set (CPACK_PACKAGING_INSTALL_PREFIX  "${CMAKE_INSTALL_PREFIX}")
set (CPACK_PACKAGE_INSTALL_PREFIX    "${CMAKE_INSTALL_PREFIX}")
set (CPACK_PACKAGE_INSTALL_DIRECTORY "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}")
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
