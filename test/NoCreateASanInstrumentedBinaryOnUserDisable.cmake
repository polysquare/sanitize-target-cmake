# /test/NoCreateASanInstrumentedBinaryOnUserDisable.cmake
# If SANITIZERS_USE_ASAN is set to OFF and include (SanitizeTarget)
# is called, then a target called target_asan should not be created.
#
# See LICENCE.md for Copyright information

set (SANITIZERS_USE_ASAN OFF CACHE BOOL "" FORCE)

include (SanitizeTarget)
include (CMakeUnit)

set (SOURCE_FILE ${CMAKE_CURRENT_BINARY_DIR}/Source.cpp)
set (SOURCE_FILE_CONTENTS
     "int main ()\n"
     "{\n"
     "    return 0\;\n"
     "}\n")
file (WRITE ${SOURCE_FILE} ${SOURCE_FILE_CONTENTS})
set (TARGET target)

add_executable (${TARGET} ${SOURCE_FILE})
assert_target_does_not_exist (${TARGET}_asan)
