# Set CMake minimum version
cmake_minimum_required (VERSION 3.10.2)
 
# Set project name
project (MonsterBalls)
# Set CMake modules search path
set (CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/Modules)
# Include UrhoCommon.cmake module after setting project name
include (UrhoCommon)
# Define target name
set (TARGET_NAME MonsterBalls)

# Define source files
#define_source_files ()

add_subdirectory(src)

# Setup target with resource copying
#setup_main_executable ()
