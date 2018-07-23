cmake_minimum_required(VERSION 2.8)

# inside rtabmap project (see below for external build)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
SET(RTABMap_INCLUDE_DIR /usr/local/opt/rtabmap-0.17.1/include/rtabmap-0.17/)
SET(RTABMap_LIBRARIES 
    /usr/local/opt/rtabmap-0.17.1/lib/librtabmap_utilite.so
	/usr/local/opt/rtabmap-0.17.1/lib/librtabmap_core.so
)  

if(POLICY CMP0020)
	cmake_policy(SET CMP0020 OLD)
endif()

#find_package(RTABMap REQUIRED)
find_package(OpenCV REQUIRED)
find_package(PCL REQUIRED)

SET(INCLUDE_DIRS
	${RTABMap_INCLUDE_DIR}
    ${OpenCV_INCLUDE_DIRS}
    ${PCL_INCLUDE_DIRS}
)

SET(LIBRARIES
	${RTABMap_LIBRARIES}
	${OpenCV_LIBRARIES}
	${PCL_LIBRARIES}
)

INCLUDE_DIRECTORIES(${INCLUDE_DIRS})

ADD_EXECUTABLE(rgbd_dataset main.cpp)
  
TARGET_LINK_LIBRARIES(rgbd_dataset ${LIBRARIES})
