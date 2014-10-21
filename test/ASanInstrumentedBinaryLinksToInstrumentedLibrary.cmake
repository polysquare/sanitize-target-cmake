# /test/ASanInstrumentedBinaryLinksToInstrumentedLibrary.cmake
# If SANITIZERS_USE_ASAN is set to ON and include (SanitizeTarget)
# is called, then a target called executable_asan and library_asan should
# be created, and executable_asan should be linked to library_asan when
# executable is linked to library
#
# See LICENCE.md for Copyright information

set (SANITIZERS_USE_ASAN ON CACHE BOOL "" FORCE)

include (SanitizeTarget)
include (CMakeUnit)

set (LIBRARY_SOURCE_FILE ${CMAKE_CURRENT_BINARY_DIR}/LibrarySource.c)
set (LIBRARY_SOURCE_FILE_CONTENTS
     "int function ()\n"
     "{\n"
     "    return 0\;\n"
     "}\n")
file (WRITE ${LIBRARY_SOURCE_FILE} ${LIBRARY_SOURCE_FILE_CONTENTS})
set (LIBRARY_TARGET library)

set (EXECUTABLE_SOURCE_FILE ${CMAKE_CURRENT_BINARY_DIR}/ExecutableSource.cpp)
set (EXECUTABLE_SOURCE_FILE_CONTENTS
     "extern \"C\" int function ()\;\n"
     "int main ()\n"
     "{\n"
     "    return function ()\;\n"
     "}\n")
file (WRITE ${EXECUTABLE_SOURCE_FILE} ${EXECUTABLE_SOURCE_FILE_CONTENTS})
set (EXECUTABLE_TARGET executable)

add_library (${LIBRARY_TARGET} SHARED ${LIBRARY_SOURCE_FILE})
sanitizer_add_sanitization_to_target (${LIBRARY_TARGET})

add_executable (${EXECUTABLE_TARGET} ${EXECUTABLE_SOURCE_FILE})
target_link_libraries (${EXECUTABLE_TARGET} ${LIBRARY_TARGET})
sanitizer_add_sanitization_to_target (${EXECUTABLE_TARGET})

assert_target_is_linked_to (${EXECUTABLE_TARGET}_asan
                            ${LIBRARY_TARGET}_asan)
