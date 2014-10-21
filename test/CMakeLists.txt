# /tests/CMakeLists.txt
# Main entry point for the accelerate-target-cmake tests.
#
# See LICENCE.md for Copyright information

if (POLICY CMP0025)

    cmake_policy (SET CMP0025 NEW)

endif (POLICY CMP0025)

project (SanitizeTargetCMakeTests)
cmake_minimum_required (VERSION 2.8)

# We assume that it is one-above us
set (SANITIZE_RELATIVE_CMAKE_DIRECTORY
     ${CMAKE_CURRENT_SOURCE_DIR}/..)
get_filename_component (SANITIZE_CMAKE_DIRECTORY
                        ${SANITIZE_RELATIVE_CMAKE_DIRECTORY}
                        ABSOLUTE)
set (CMAKE_UNIT_DIRECTORY
     ${SANITIZE_CMAKE_DIRECTORY}/cmake-unit)

set (SANITIZE_INITIAL_CACHE_CONTENTS
     "set (CMAKE_C_COMPILER\n"
     "     ${CMAKE_C_COMPILER}\n"
     "     CACHE STRING \"\" FORCE)\n"
     "set (CMAKE_CXX_COMPILER\n"
     "     ${CMAKE_CXX_COMPILER}\n"
     "     CACHE STRING \"\" FORCE)\n"
     "set (CMAKE_GENERATOR\n"
     "     \"${CMAKE_GENERATOR}\"\n"
     "     CACHE STRING \"\" FORCE)\n")

set (CMAKE_MODULE_PATH
     ${CMAKE_UNIT_DIRECTORY}
     ${SANITIZE_CMAKE_DIRECTORY}
     ${CMAKE_MODULE_PATH})

foreach (PATH ${CMAKE_MODULE_PATH})
     set (SANITIZE_INITIAL_CACHE_CONTENTS
          "${SANITIZE_INITIAL_CACHE_CONTENTS}\n"
          "set (CMAKE_MODULE_PATH ${PATH} \${CMAKE_MODULE_PATH}\n"
          "     CACHE STRING \"\" FORCE)\n")
endforeach ()

# Check for the presence of AddressSanitizer, MemorySanitizer, ThreadSanitizer,
# UndefinedBehaviourSanitizer. If any of these get set to OFF, the sanitizer
# is not available.
set (SANITIZERS_USE_ASAN ON CACHE FORCE "")
set (SANITIZERS_USE_MSAN ON CACHE FORCE "")
set (SANITIZERS_USE_TSAN ON CACHE FORCE "")
set (SANITIZERS_USE_UBSAN ON CACHE FORCE "")

include (CMakeUnitRunner)
include (SanitizeTarget)

bootstrap_cmake_unit (INITIAL_CACHE_CONTENTS
                      SANITIZE_INITIAL_CACHE_CONTENTS)

if (SANITIZERS_USE_ASAN)

    add_cmake_test (NoASanFlagDisablesCreationOfInstrumentedBinary)
    add_cmake_test (NoCreateASanInstrumentedBinaryOnUserDisable)
    add_cmake_build_test (CreateASanInstrumentedBinary
                          CreateASanInstrumentedBinaryVerify)
    add_cmake_build_test (CreateASanInstrumentedLibrary
                          CreateASanInstrumentedLibraryVerify)
    add_cmake_build_test (ASanInstrumentedBinaryLinksToInstrumentedLibrary
                          ASanInstrumentedBinaryLinksToInstrumentedLibraryVerify)

endif (SANITIZERS_USE_ASAN)

if (SANITIZERS_USE_MSAN)

    add_cmake_build_test (CreateMSanInstrumentedBinary
                          CreateMSanInstrumentedBinaryVerify)

    if (POLYSQUARE_HAVE_SANITIZE_MEMORY_TRACK_ORIGINS)

        add_cmake_build_test (MSanInstrumentedBinaryTracksOrigins
                              MSanInstrumentedBinaryTracksOriginsVerify)

    endif (POLYSQUARE_HAVE_SANITIZE_MEMORY_TRACK_ORIGINS)

endif (SANITIZERS_USE_MSAN)

if (SANITIZERS_USE_UBSAN)

    add_cmake_build_test (CreateUBSanInstrumentedBinary
                          CreateUBSanInstrumentedBinaryVerify)

    if (POLYSQUARE_HAVE_UBSAN_UNSIGNED_INTEGER_OVERFLOW)

        add_cmake_build_test (UBSanInstrumentedBinaryUnsignedIntOverflow
                              UBSanInstrumentedBinaryUnsignedIntOverflowVerify)

    endif (POLYSQUARE_HAVE_UBSAN_UNSIGNED_INTEGER_OVERFLOW)

    if (POLYSQUARE_HAVE_UBSAN_NO_SANITIZE_RECOVER)

        add_cmake_build_test (UBSanInstrumentedBinaryNoRecover
                              UBSanInstrumentedBinaryNoRecoverVerify)

    endif (POLYSQUARE_HAVE_UBSAN_NO_SANITIZE_RECOVER)


endif (SANITIZERS_USE_UBSAN)

if (SANITIZERS_USE_TSAN)

    add_cmake_build_test (CreateTSanInstrumentedBinary
                          CreateTSanInstrumentedBinaryVerify)

endif (SANITIZERS_USE_TSAN)

