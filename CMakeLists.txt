CMAKE_MINIMUM_REQUIRED(VERSION 3.2.0)

# Set the target and the target source
SET( TARGET "mor-coupling" )

FIND_PACKAGE(deal.II 9.2
  HINTS ${deal.II_DIR} ${DEAL_II_DIR} ../ ../../ $ENV{DEAL_II_DIR}
  )
IF(NOT ${deal.II_FOUND})
  MESSAGE(FATAL_ERROR "\n"
    "*** Could not locate deal.II. ***\n\n"
    "You may want to either pass a flag -DDEAL_II_DIR=/path/to/deal.II to cmake\n"
    "or set an environment variable \"DEAL_II_DIR\" that contains this path."
    )
ENDIF()

IF(NOT CMAKE_BUILD_TYPE)
  SET(CMAKE_BUILD_TYPE "Debug")
  MESSAGE(STATUS "No build type specified. Building in ${CMAKE_BUILD_TYPE} mode.")
ENDIF()

# Print the current build type
MESSAGE(STATUS "Build type: ${CMAKE_BUILD_TYPE}")

# Enable a switchable dimension choice
IF (NOT DEFINED DIM)
        SET(DIM 2)
ENDIF()
ADD_DEFINITIONS(-DDIM=${DIM})

# Set the include directory and the name of the project
PROJECT(${TARGET})
INCLUDE_DIRECTORIES(${CMAKE_SOURCE_DIR}/include/dealii-adapter/include)
SET(PYBIND11_PYTHON_VERSION "3" CACHE STRING "Python version to use for compiling the example library")

LIST(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")
INCLUDE(pymor_deal_ii_setup_target)
ADD_SUBDIRECTORY(lib)
