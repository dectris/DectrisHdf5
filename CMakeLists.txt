PROJECT(DectrisHdf5)
CMAKE_MINIMUM_REQUIRED( VERSION 2.8.9)


# Tell hdf5 that we are manually overriding certain settings
SET(HDF5_EXTERNALLY_CONFIGURED 1)
# Avoid duplicating names of installed libraries
SET(HDF5_EXTERNAL_LIB_PREFIX "Dectris")

# set options for bulding hdf5
SET (BUILD_SHARED_LIBS ON CACHE BOOL "Build Shared Libraries")
SET (HDF5_BUILD_TOOLS ON CACHE BOOL "Build HDF5 Tools")
SET (HDF5_BUILD_HL_LIB ON CACHE BOOL "Build HIGH Level HDF5 Library")
# Add the sub project
ADD_SUBDIRECTORY(hdf5-1.8.11)
