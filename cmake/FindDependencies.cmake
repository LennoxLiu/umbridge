# copy the cpp-httplib header file into the include directory
file(COPY ${CMAKE_SOURCE_DIR}/external/cpp-httplib/httplib.h DESTINATION ${CMAKE_SOURCE_DIR}/include/umbridge/external/)

# copy the cpp-httplib header file into the include directory
file(COPY ${CMAKE_SOURCE_DIR}/external/json/single_include/nlohmann/json.hpp DESTINATION ${CMAKE_SOURCE_DIR}/include/umbridge/external/)
