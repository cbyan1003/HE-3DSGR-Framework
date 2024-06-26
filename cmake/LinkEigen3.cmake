####################
# LinkEigen3.cmake #
####################
if(TARGET Eigen3::Eigen)
  target_link_libraries(${targetname} InstanceFusion Eigen3::Eigen)
elseif(EIGEN3_INCLUDE_DIR)
  target_include_directories(${targetname} InstanceFusion ${EIGEN3_INCLUDE_DIR})
else()
  MESSAGE(FATAL_ERROR "cannot find eigen3")
endif()