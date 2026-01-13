# FindLibObs.cmake
# Finds the LibObs library and headers.

find_path(LibObs_INCLUDE_DIR
    NAMES obs.h
    HINTS
      ${LibObs_DIR}
      ${OBS_DIR}
      ${CMAKE_CURRENT_SOURCE_DIR}/deps/obs-studio
      ${CMAKE_CURRENT_SOURCE_DIR}/../deps/obs-studio
      ${CMAKE_CURRENT_SOURCE_DIR}/deps/obs-source/libobs
      ${CMAKE_CURRENT_SOURCE_DIR}/../deps/obs-source/libobs
      $ENV{LibObs_DIR}
      $ENV{OBS_DIR}
    PATH_SUFFIXES include libobs
)

find_library(LibObs_LIB
    NAMES obs libobs
    HINTS
      ${LibObs_DIR}
      ${OBS_DIR}
      ${CMAKE_CURRENT_SOURCE_DIR}/deps/obs-studio
      ${CMAKE_CURRENT_SOURCE_DIR}/../deps/obs-studio
      $ENV{LibObs_DIR}
      $ENV{OBS_DIR}
    PATH_SUFFIXES bin/64bit bin/32bit lib
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(LibObs
    REQUIRED_VARS LibObs_LIB LibObs_INCLUDE_DIR
)

if(LibObs_FOUND AND NOT TARGET libobs)
    add_library(libobs UNKNOWN IMPORTED)
    set_target_properties(libobs PROPERTIES
        IMPORTED_LOCATION "${LibObs_LIB}"
        INTERFACE_INCLUDE_DIRECTORIES "${LibObs_INCLUDE_DIR}"
    )
endif()

mark_as_advanced(LibObs_INCLUDE_DIR LibObs_LIB)
