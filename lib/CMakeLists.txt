# CMake minimum version
CMAKE_MINIMUM_REQUIRED(VERSION 3.2.0)

# Set the name of the project and target:
SET(TARGET "heat_equation")
SET(_src ${TARGET}.cc)

# Set pybind version
ADD_SUBDIRECTORY(pybind11)

DEAL_II_INITIALIZE_CACHED_VARIABLES()

pybind11_add_module(dealii_${TARGET} py_${TARGET}.cc ${TARGET}.cc)

PYMOR_DEAL_II_SETUP_TARGET(dealii_${TARGET})
DEAL_II_QUERY_GIT_INFORMATION()
SET_PROPERTY(TARGET  dealii_${TARGET}  APPEND  PROPERTY  COMPILE_DEFINITIONS
            GIT_BRANCH="${GIT_BRANCH}"
            GIT_REVISION="${GIT_REVISION}"
            GIT_SHORTREV="${GIT_SHORTREV}")

# the environment variable precice_DIR is searched by default
FIND_PACKAGE(precice 2.4
        HINTS ${precice_DIR} ${PRECICE_DIR} $ENV{PRECICE_DIR}
  )
IF(NOT ${precice_FOUND})
   MESSAGE(FATAL_ERROR "\n"
    "*** Could not locate a (sufficiently recent) version of preCICE. ***\n\n"
    "You may want to either pass a flag -Dprecice_DIR=/path/to/precice to cmake\n"
    "(where the path points to the installation prefix or the build directory)\n"
    " or set an environment variable \"precice_DIR\" that contains this path."
    )
ENDIF()
MESSAGE(STATUS "Found preCICE version ${precice_VERSION} at ${precice_DIR}")
TARGET_LINK_LIBRARIES(dealii_${TARGET} PRIVATE precice::precice)
