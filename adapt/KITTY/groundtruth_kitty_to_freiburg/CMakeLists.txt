cmake_minimum_required(VERSION 2.8)

project(groundtruth_kitty_to_freiburg)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
set(Boost_INCLUDE_DIR /usr/local/opt/boost-1.60/include)
set(EIGEN3_INCLUDE_DIR /usr/local/opt/eigen-3.3.4/include)
aux_source_directory(. SRC_LIST)

find_package(Boost COMPONENTS date_time filesystem system)
find_package(OpenCV REQUIRED)

include_directories(${OpenCV_INCLUDE_DIRS})
include_directories(${Boost_INCLUDE_DIRS})
include_directories(${EIGEN_INCLUDE_DIRS})

add_executable(${PROJECT_NAME} ${SRC_LIST})

target_link_libraries(${PROJECT_NAME}
                      ${Boost_LIBRARIES}
                      ${OpenCV_LIBS}
		      ${Eigen_LIBRARIES}
                      )
