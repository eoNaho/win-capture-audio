cmake_minimum_required(VERSION 3.20)

project(win-capture-audio-tests)

include(FetchContent)
FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/refs/tags/v1.13.0.zip
)
# For Windows: Prevent overriding the parent project's compiler/linker settings
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

enable_testing()

add_executable(
  process-utils-test
  test-process-utils.cpp
  ../src/process-utils.cpp
)

target_link_libraries(
  process-utils-test
  GTest::gtest_main
  wil
)

# Add WIL include directory
target_include_directories(process-utils-test PRIVATE ../deps/wil/include)

# Discover tests
include(GoogleTest)
gtest_discover_tests(process-utils-test)
