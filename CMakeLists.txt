cmake_minimum_required(VERSION 3.16)
project(PGOBench CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Build type default
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

# Options to control PGO behavior
option(PGO_GENERATE "Build with profile generation instrumentation" OFF)
option(PGO_USE "Build using collected profile data" OFF)

# Where raw profile data goes during training
set(PGO_PROFILE_DIR "${CMAKE_BINARY_DIR}/profiles" CACHE PATH "Profile data directory")
set(PGO_PROFILE_FILE "${PGO_PROFILE_DIR}/default.profdata" CACHE FILEPATH "Merged profdata file")

add_executable(sort_bench bench/sort_bench.cpp)

# Common optimization
target_compile_options(sort_bench PRIVATE -O3)
target_link_options(sort_bench PRIVATE -O3)

# Clang/LLVM-style PGO
if(PGO_GENERATE)
  message(STATUS "PGO generation enabled")
  file(MAKE_DIRECTORY "${PGO_PROFILE_DIR}")
  target_compile_options(sort_bench PRIVATE -fprofile-instr-generate)
  target_link_options(sort_bench PRIVATE -fprofile-instr-generate)
endif()

if(PGO_USE)
  message(STATUS "PGO use enabled: ${PGO_PROFILE_FILE}")
  target_compile_options(sort_bench PRIVATE -fprofile-instr-use=${PGO_PROFILE_FILE})
endif()
