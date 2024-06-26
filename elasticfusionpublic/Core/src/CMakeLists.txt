cmake_minimum_required(VERSION 3.0.2)
if(POLICY CMP0007)
  cmake_policy(SET CMP0007 NEW)
endif()

project(libefusion)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_SOURCE_DIR}")

find_package(Pangolin 0.1 REQUIRED)
find_package(CUDA REQUIRED)
find_package(SuiteSparse REQUIRED)
# set(CUDA_HOST_COMPILER "/usr/bin/g++-")
set(CUDA_HOST_COMPILER gcc-4.9)

set(efusion_SHADER_DIR "${CMAKE_CURRENT_SOURCE_DIR}/Shaders" CACHE PATH "Where the shaders live")
message("efusion_SHADER_DIR:"${efusion_SHADER_DIR})
# set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD 14)
file(GLOB srcs *.cpp)
file(GLOB utils_srcs Utils/*.cpp)
file(GLOB shader_srcs Shaders/*.cpp)
file(GLOB cuda Cuda/*.cu)
file(GLOB containers Cuda/containers/*.cpp)

if(WIN32)
  file(GLOB hdrs *.h)
  file(GLOB utils_hdrs Utils/*.h)
  file(GLOB shader_hdrs Shaders/*.h)
  file(GLOB cuda_hdrs Cuda/*.cuh)
  file(GLOB containers_hdrs Cuda/containers/*.hpp)
endif()

set(CUDA_ARCH_BIN "75")
set(CUDA_ARCH_PTX "75")              

SET(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR})
include(CudaComputeTargetFlags.cmake)                  
APPEND_TARGET_ARCH_FLAGS()

set(CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS}  "-Xcompiler;-fPIC;")           
set(CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS} "--ftz=true;--prec-div=false;--prec-sqrt=false") 

CUDA_COMPILE(cuda_objs ${cuda})

if(WIN32)
  set(ADDITIONAL_CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS})
endif()

set(CMAKE_CXX_FLAGS ${ADDITIONAL_CMAKE_CXX_FLAGS} "-O3 -msse2 -msse3 -Wall -std=c++11 -DSHADER_DIR=${efusion_SHADER_DIR}")
#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g -Wall -std=c++11 -DSHADER_DIR=${efusion_SHADER_DIR}")
  
if(WIN32)
  add_definitions(-DWIN32_LEAN_AND_MEAN)
  add_definitions(-DNOMINMAX)
  set (EXTRA_WINDOWS_LIBS ${EXTRA_WINDOWS_LIBS} ws2_32)
endif()

add_library(efusion SHARED 
            ${srcs}
            ${utils_srcs}
            ${shader_srcs}
            ${cuda} 
            ${cuda_objs} 
            ${containers}
            ${hdrs}
            ${utils_hdrs}
            ${shader_hdrs}
            ${cuda_hdrs} 
            ${containers_hdrs}
)

target_include_directories(efusion PUBLIC
                           $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
                           ${Pangolin_INCLUDE_DIRS}
                           ${CUDA_INCLUDE_DIRS}
                           ${EIGEN_INCLUDE_DIRS}
                           ${SUITESPARSE_INCLUDE_DIRS}
)

target_link_libraries(efusion PUBLIC
                      ${Eigen_LIBRARIES}
                      ${Pangolin_LIBRARIES}
                      ${CUDA_LIBRARIES}
                      ${SUITESPARSE_LIBRARIES}
					  ${EXTRA_WINDOWS_LIBS}
) 

INSTALL(TARGETS efusion
            RUNTIME DESTINATION bin
            LIBRARY DESTINATION lib
            ARCHIVE DESTINATION lib
)
