INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR}/hdf5-1.8.11)
add_executable(playground_test playground_test.cpp)
target_link_libraries(playground_test ${HDF5_LIB_TARGET})
