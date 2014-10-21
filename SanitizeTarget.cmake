# /SanitizeTarget.cmake
#
# CMake macro to add sanitization checks to a target. Because sanitization
# checks cannot be added concurrently with each other, a separate
# binary is added for each sanitization check added, for instance
# TARGET_msan, TARGET_ubsan. These will be added as dependencies to the
# ALL target by default, or an ALL_msan, ALL_ubsan, etc target by option.
#
# See LICENCE.md for Copyright information.

set (SANITIZERS_CMAKE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})

set (CMAKE_MODULE_PATH
     ${CMAKE_MODULE_PATH}
     ${SANITIZERS_CMAKE_DIRECTORY}/tooling-cmake-util
     ${SANITIZERS_CMAKE_DIRECTORY}/parallel-build-target-utils
     ${SANITIZERS_CMAKE_DIRECTORY}/sanitizers-cmake)

include (CheckCXXCompilerFlag)
include (CMakeParseArguments)
include (PolysquareToolingUtil)
include (ParallelBuildTargetUtils)

function (_bootstrap_sanitizer)

    set (BOOTSTRAP_SANITIZER_SINGLEVAR_ARGS
         SHORT_NAME
         LONG_NAME
         PACKAGE_NAME
         DESCRIPTION
         SUFFIX)
    cmake_parse_arguments (BOOT_SANITIZER
                           ""
                           "${BOOTSTRAP_SANITIZER_SINGLEVAR_ARGS}"
                           ""
                           ${ARGN})

    set (OPTION_DESC
         "Create ${BOOT_SANITIZER_DESCRIPTION} instrumented binaries (ending "
         "with _${BOOT_SANITIZER_SUFFIX})")
    string (REPLACE ";" "" OPTION_DESC  "${OPTION_DESC}")
    option (SANITIZERS_USE_${BOOT_SANITIZER_SHORT_NAME} "${OPTION_DESC}" OFF)

    if (SANITIZERS_USE_${BOOT_SANITIZER_SHORT_NAME})

        # Check if we have the sanitizer and if so report that we do
        find_package (${BOOT_SANITIZER_PACKAGE_NAME})

        if (HAVE_${BOOT_SANITIZER_LONG_NAME})

            set (SANITIZER_STATUS
                 "supported: ${${BOOT_SANITIZER_LONG_NAME}_FLAG}")

        else (HAVE_${BOOT_SANITIZER_LONG_NAME})

            set (SANITIZER_STATUS "not supported")
            set (SANITIZERS_USE_${BOOT_SANITIZER_SHORT_NAME} OFF PARENT_SCOPE)

        endif (HAVE_${BOOT_SANITIZER_LONG_NAME})

    else (SANITIZERS_USE_${BOOT_SANITIZER_SHORT_NAME})

        set (SANITIZER_STATUS "disabled")

    endif (SANITIZERS_USE_${BOOT_SANITIZER_SHORT_NAME})

    message (STATUS "${BOOT_SANITIZER_DESCRIPTION} ${SANITIZER_STATUS}")

endfunction (_bootstrap_sanitizer)

function (_sanitizer_add_flags FLAGS_ADD_RETURN)

    set (ADD_FLAGS_SINGLEVAR_ARGS
         SHORT_NAME
         ADDITIONAL_FLAG_SWITCH
         ADDITIONAL_FLAG_LONG_NAME)

    cmake_parse_arguments (ADD_FLAGS
                           ""
                           "${ADD_FLAGS_SINGLEVAR_ARGS}"
                           ""
                           ${ARGN})

    if (SANITIZERS_USE_${ADD_FLAGS_SHORT_NAME})

        set (PREVIOUS_FLAGS "${CMAKE_CXX_FLAGS_${ADD_FLAGS_SHORT_NAME}}")
        set (TEST_FLAGS
             "${PREVIOUS_FLAGS} ${ADD_FLAGS_ADDITIONAL_FLAG_SWITCH}")
        set (CMAKE_REQUIRED_FLAGS "${TEST_FLAGS}")
        check_cxx_compiler_flag ("${TEST_FLAGS}"
                                 HAVE_${ADD_FLAGS_ADDITIONAL_FLAG_LONG_NAME})
        unset (CMAKE_REQUIRED_FLAGS)

        if (HAVE_${ADD_FLAGS_ADDITIONAL_FLAG_LONG_NAME})

            set (${FLAGS_ADD_RETURN}
                 "${${FLAGS_ADD_RETURN}} ${ADD_FLAGS_ADDITIONAL_FLAG_SWITCH}"
                 PARENT_SCOPE)
            set (SANITIZERS_HAVE_${ADD_FLAGS_ADDITIONAL_FLAG_LONG_NAME} TRUE
                 PARENT_SCOPE)

        endif (HAVE_${ADD_FLAGS_ADDITIONAL_FLAG_LONG_NAME})

    endif (SANITIZERS_USE_${ADD_FLAGS_SHORT_NAME})

endfunction (_sanitizer_add_flags FLAGS_ADD_RETURN)

function (_add_sanitizer_to_target)

    set (ADD_SANITIZER_OPTION_ARGS
         ${_ALL_POLYSQUARE_SANITIZATION_OPTION_ARGS})
    set (ADD_SANITIZER_SINGLEVAR_ARGS
         SHORT_NAME
         SUFFIX
         TARGET)
    set (ADD_SANITIZER_MUTLIVAR_ARGS
         ${_ALL_POLYSQUARE_SANITIZATION_MULTIVAR_ARGS}
         COMPILE_FLAGS
         LINK_FLAGS)

    cmake_parse_arguments (ADD_SANITIZER
                           "${ADD_SANITIZER_OPTION_ARGS}"
                           "${ADD_SANITIZER_SINGLEVAR_ARGS}"
                           "${ADD_SANITIZER_MUTLIVAR_ARGS}"
                           ${ARGN})

    # Eg, NO_ASAN or SANITIZERS_USE_ASAN
    if (NOT SANITIZERS_USE_${ADD_SANITIZER_SHORT_NAME} OR
        ADD_SANITIZER_NO_${ADD_SANITIZER_SHORT_NAME})

        return ()

    endif (NOT SANITIZERS_USE_${ADD_SANITIZER_SHORT_NAME} OR
           ADD_SANITIZER_NO_${ADD_SANITIZER_SHORT_NAME})

    psq_forward_options (ADD_SANITIZER MIRRORED_BUILD_FORWARD_OPTIONS
                         MULTIVAR_ARGS COMPILE_FLAGS LINK_FLAGS)
    psq_create_mirrored_build_target (${TARGET} ${ADD_SANITIZER_SUFFIX}
                                      ${MIRRORED_BUILD_FORWARD_OPTIONS})

endfunction (_add_sanitizer_to_target)

function (sanitizer_add_sanitization_to_target TARGET)

    set (SANITIZATION_OPTION_ARGS
         NO_ASAN
         NO_MSAN
         NO_TSAN
         NO_UBSAN)

    cmake_parse_arguments (SANITIZATION
                           "${SANITIZATION_OPTION_ARGS}"
                           ""
                           "${SANITIZATION_MULTIVAR_ARGS}"
                           ${ARGN})

    psq_forward_options (SANITIZATION SANITIZER_FORWARD_OPTIONS
                         OPTION_ARGS ${SANITIZATION_OPTION_ARGS})

    set (POLYSQUARE_MSAN_FLAGS
         "${CMAKE_CXX_FLAGS_MSAN} ${POLYSQUARE_MSAN_FLAGS_ADD}")
    set (POLYSQUARE_UBSAN_FLAGS
         "${CMAKE_CXX_FLAGS_UBSAN} ${POLYSQUARE_UBSAN_FLAGS_ADD}")

    # The C and CXX flags for sanitizers appear to be the same, so just
    # use the CXX flags for now.
    _add_sanitizer_to_target (SHORT_NAME ASAN
                              SUFFIX asan
                              TARGET ${TARGET}
                              COMPILE_FLAGS ${CMAKE_CXX_FLAGS_ASAN}
                              LINK_FLAGS ${CMAKE_SHARED_LINKER_FLAGS_ASAN}
                              ${SANITIZER_FORWARD_OPTIONS})
    _add_sanitizer_to_target (SHORT_NAME MSAN
                              SUFFIX msan
                              TARGET ${TARGET}
                              COMPILE_FLAGS ${POLYSQUARE_MSAN_FLAGS}
                              LINK_FLAGS ${CMAKE_SHARED_LINKER_FLAGS_MSAN}
                              ${SANITIZER_FORWARD_OPTIONS})
    _add_sanitizer_to_target (SHORT_NAME UBSAN
                              SUFFIX ubsan
                              TARGET ${TARGET}
                              COMPILE_FLAGS ${POLYSQUARE_UBSAN_FLAGS}
                              LINK_FLAGS ${CMAKE_SHARED_LINKER_FLAGS_UBSAN}
                              ${SANITIZER_FORWARD_OPTIONS})
    _add_sanitizer_to_target (SHORT_NAME TSAN
                              SUFFIX tsan
                              TARGET ${TARGET}
                              COMPILE_FLAGS ${CMAKE_CXX_FLAGS_TSAN}
                              LINK_FLAGS ${CMAKE_SHARED_LINKER_FLAGS_TSAN}
                              ${SANITIZER_FORWARD_OPTIONS})

endfunction (sanitizer_add_sanitization_to_target)

# Bootstrap all the sanitizers
_bootstrap_sanitizer (SHORT_NAME ASAN
                      LONG_NAME ADDRESS_SANITIZER
                      PACKAGE_NAME ASan
                      DESCRIPTION AddressSanitizer
                      SUFFIX asan)
_bootstrap_sanitizer (SHORT_NAME MSAN
                      LONG_NAME MEMORY_SANITIZER
                      PACKAGE_NAME MSan
                      DESCRIPTION MemorySanitizer
                      SUFFIX msan)
_bootstrap_sanitizer (SHORT_NAME UBSAN
                      LONG_NAME UNDEFINED_BEHAVIOR_SANITIZER
                      PACKAGE_NAME UBSan
                      DESCRIPTION UndefinedBehaviourSanitizer
                      SUFFIX ubsan)
_bootstrap_sanitizer (SHORT_NAME TSAN
                      LONG_NAME THREAD_SANITIZER
                      PACKAGE_NAME TSan
                      DESCRIPTION ThreadSanitizer
                      SUFFIX tsan)

# MemorySanitizer-specific options
_sanitizer_add_flags (POLYSQUARE_MSAN_FLAGS_ADD
                      SHORT_NAME MSAN
                      ADDITIONAL_FLAG_SWITCH
                      "-fsanitize-memory-track-origins=2"
                      ADDITIONAL_FLAG_LONG_NAME
                      SANITIZE_MEMORY_TRACK_ORIGINS)

# UndefinedBehaviourSanitizer-specific options
_sanitizer_add_flags (POLYSQUARE_UBSAN_FLAGS_ADD
                      SHORT_NAME UBSAN
                      ADDITIONAL_FLAG_SWITCH
                      "-fsanitize=unsigned-integer-overflow"
                      ADDITIONAL_FLAG_LONG_NAME
                      UBSAN_UNSIGNED_INTEGER_OVERFLOW)
_sanitizer_add_flags (POLYSQUARE_UBSAN_FLAGS_ADD
                      SHORT_NAME UBSAN
                      ADDITIONAL_FLAG_SWITCH
                      "-fno-sanitize-recover"
                      ADDITIONAL_FLAG_LONG_NAME
                      UBSAN_NO_SANITIZE_RECOVER)

