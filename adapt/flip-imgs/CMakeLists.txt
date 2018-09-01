cmake_minimum_required(VERSION 2.8)

project(flip_imgs)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
set(Boost_INCLUDE_DIR /usr/local/opt/boost-1.60/include)
aux_source_directory(. SRC_LIST)

find_package(Boost COMPONENTS date_time filesystem system REQUIRED)
find_package(OpenCV REQUIRED)

include_directories(${Boost_INCLUDE_DIRS})
include_directories(${OpenCV_INCLUDE_DIRS})

add_executable(${PROJECT_NAME} ${SRC_LIST})

target_link_libraries(${PROJECT_NAME}
                      ${Boost_LIBRARIES}
					  ${OpenCV_LIBS})
