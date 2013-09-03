CMAKE_MINIMUM_REQUIRED( VERSION 2.8.11)
PROJECT(DectrisHdf5)

IF(NOT CMAKE_BUILD_TYPE)
  SET ( CMAKE_BUILD_TYPE Release )
ENDIF()

SET(VERSION 1.8.11)


# Tell hdf5 that we are manually overriding certain settings
SET(HDF5_EXTERNALLY_CONFIGURED 1)
# Avoid duplicating names of installed libraries
SET(HDF5_EXTERNAL_LIB_PREFIX "dectris")

# set options for bulding hdf5
SET (BUILD_SHARED_LIBS ON CACHE BOOL "Build Shared Libraries")
SET (HDF5_BUILD_TOOLS ON CACHE BOOL "Build HDF5 Tools")
SET (HDF5_BUILD_HL_LIB ON CACHE BOOL "Build HIGH Level HDF5 Library")
# Add the sub project
ADD_SUBDIRECTORY(hdf5-${VERSION})

SET(INCLUDE_INSTALL_DIR include/  )
IF(WIN32)
  SET(LIB_INSTALL_DIR bin/ )
  SET(CMAKE_INSTALL_DIR cmake/)
ELSE()
  SET(LIB_INSTALL_DIR lib/ )
  SET(CMAKE_INSTALL_DIR lib/DectrisHdf5/cmake/)
ENDIF()


include(CMakePackageConfigHelpers)
configure_package_config_file(cmake/DectrisHdf5Config.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/DectrisHdf5Config.cmake
                                 INSTALL_DESTINATION ${CMAKE_INSTALL_DIR}
                                 PATH_VARS INCLUDE_INSTALL_DIR LIB_INSTALL_DIR)
write_basic_package_version_file(${CMAKE_CURRENT_BINARY_DIR}/DectrisHdf5Config-version.cmake
                                    VERSION ${VERSION}
                                    COMPATIBILITY ExactVersion )
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/DectrisHdf5Config.cmake ${CMAKE_CURRENT_BINARY_DIR}/DectrisHdf5Config-version.cmake
        DESTINATION ${CMAKE_INSTALL_DIR} )
        
        
IF(WIN32)
SET(CPACK_PACKAGE_INSTALL_DIRECTORY "DectrisHdf5-${VERSION}")
SET(CPACK_PACKAGE_VERSION ${VERSION})
set(CPACK_PACKAGE_VENDOR Dectris Ltd.)
set(CPACK_PACKAGE_FILE_NAME DectrisHdf5-${VERSION})
# Generate guid for every major release
execute_process(COMMAND
                python -c "import uuid; print uuid.uuid5(uuid.NAMESPACE_DNS,\"DectrisHdf5-${VERSION}.dectris.com\")"
                OUTPUT_VARIABLE CPACK_WIX_UPGRADE_GUID
                OUTPUT_STRIP_TRAILING_WHITESPACE
)
MESSAGE(STATUS "WIX Upgrade GUID ${CPACK_WIX_UPGRADE_GUID}" )
set(CPACK_GENERATOR WIX)

INCLUDE(CPack)
ENDIF()

