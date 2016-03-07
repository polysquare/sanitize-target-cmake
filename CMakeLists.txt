# /CMakeLists.txt
#
# Main entry point for SanitizeTarget tests.
#
# See /LICENCE.md for Copyright information

include ("${CMAKE_CURRENT_LIST_DIR}/conanbuildinfo.cmake")
set (CMAKE_MODULE_PATH
     "${CMAKE_CURRENT_LIST_DIR}"
     ${CONAN_CMAKE_MODULE_PATH}  # NOLINT:correctness/quotes
     ${CMAKE_MODULE_PATH})  # NOLINT:correctness/quotes

cmake_minimum_required (VERSION 2.8)

set (_CURRENT_LIST_FILE "${CMAKE_CURRENT_LIST_FILE}")

set (SANITIZERS_USE_ASAN ON CACHE FORCE "")
set (SANITIZERS_USE_MSAN ON CACHE FORCE "")
set (SANITIZERS_USE_TSAN ON CACHE FORCE "")
set (SANITIZERS_USE_UBSAN ON CACHE FORCE "")

include ("cmake/cmake-unit/CMakeUnitRunner")
include ("cmake/cmake-unit/CMakeUnit")
include (SanitizeTarget)

# If SANITIZERS_USE_ASAN is set to ON and include (SanitizeTarget)
# is called, then a target called executable_asan and library_asan should
# be created, and executable_asan should be linked to library_asan when
# executable is linked to library
function (psq_test_asan_instrumented_binary_links_to_instrumented_library)

    function (psq_configure)

        set (SANITIZERS_USE_ASAN ON CACHE BOOL "" FORCE)

        cmake_unit_create_simple_library (library SHARED
                                          GENERATING_FILE
                                          "${_CURRENT_LIST_FILE}")
        cmake_unit_create_simple_executable (executable
                                             GENERATING_FILE
                                             "${_CURRENT_LIST_FILE}")
        target_link_libraries (executable library)
        psq_sanitizer_add_sanitization_to_target (library)
        psq_sanitizer_add_sanitization_to_target (executable)
        cmake_unit_assert_that (executable_asan is_linked_to library_asan)

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        set (LINKER_LINE "^.*executable_asan.*library_asan.*$")
        cmake_unit_assert_that (${BUILD_OUTPUT} file_contents any_line
                                matches_regex
                                ${LINKER_LINE})

    endfunction ()

    if (SANITIZERS_USE_ASAN)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND psq_configure
                                   VERIFY COMMAND psq_verify)

    endif ()

endfunction ()

# If SANITIZERS_USE_ASAN is set to ON and include (SanitizeTarget)
# is called, then a target called target_asan should be created
# along with target and -fsanitize=address should be passed when compiling it.
function (psq_test_create_asan_instrumented_binary)

    function (psq_configure)

        set (SANITIZERS_USE_ASAN ON CACHE BOOL "" FORCE)
        cmake_unit_create_simple_executable (target
                                             GENERATING_FILE
                                             "${_CURRENT_LIST_FILE}")
        psq_sanitizer_add_sanitization_to_target (target)
        cmake_unit_assert_that (target_asan target_exists)

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that (${BUILD_OUTPUT} file_contents any_line
                                matches_regex
                                "^.*-fsanitize=address.*target.cpp.*$")
        cmake_unit_assert_that (${BUILD_OUTPUT}
                                file_contents
                                any_line
                                matches_regex
                                "^.*-fsanitize=address.*target_asan.*$")

    endfunction ()

    if (SANITIZERS_USE_ASAN)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND psq_configure
                                   VERIFY COMMAND psq_verify)

    endif ()

endfunction ()

# If SANITIZERS_USE_ASAN is set to ON and include (SanitizeTarget)
# is called, then a target called target_asan should be created
# along with target and -fsanitize=address should be passed when compiling it.
function (psq_test_create_asan_instrumented_library)

    function (psq_configure)

        set (SANITIZERS_USE_ASAN ON CACHE BOOL "" FORCE)
        cmake_unit_create_simple_library (target SHARED
                                          GENERATING_FILE
                                          "${_CURRENT_LIST_FILE}")
        psq_sanitizer_add_sanitization_to_target (target)
        cmake_unit_assert_that (target_asan target_exists)
        cmake_unit_assert_that (target_asan item_has_property_with_value
                                TARGET TYPE STRING EQUAL "SHARED_LIBRARY")

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that (${BUILD_OUTPUT} file_contents any_line
                                matches_regex
                                "^.*-fsanitize=address.*target.cpp.*$")
        cmake_unit_assert_that (${BUILD_OUTPUT}
                                file_contents
                                any_line
                                matches_regex
                                "^.*-fsanitize=address.*target_asan.*$")

    endfunction ()

    if (SANITIZERS_USE_ASAN)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND psq_configure
                                   VERIFY COMMAND psq_verify)

    endif ()

endfunction ()

# If SANITIZERS_USE_MSAN is set to ON and include (SanitizeTarget)
# is called, then a target called target_msan should be created
# along with target and -fsanitize=memory should be passed when compiling it.
function (psq_test_create_msan_instrumented_binary)

    function (psq_configure)

        set (SANITIZERS_USE_MSAN ON CACHE BOOL "" FORCE)
        cmake_unit_create_simple_executable (target
                                             GENERATING_FILE
                                             "${_CURRENT_LIST_FILE}")
        psq_sanitizer_add_sanitization_to_target (target)
        cmake_unit_assert_that (target_msan target_exists)

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that (${BUILD_OUTPUT} file_contents any_line
                                matches_regex
                                "^.*-fsanitize=memory.*target.cpp.*$")
        cmake_unit_assert_that (${BUILD_OUTPUT}
                                file_contents
                                any_line
                                matches_regex
                                "^.*-fsanitize=memory.*target_msan.*$")

    endfunction ()

    if (SANITIZERS_USE_MSAN)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND psq_configure
                                   VERIFY COMMAND psq_verify)

    endif ()
endfunction ()

# If SANITIZERS_USE_TSAN is set to ON and include (SanitizeTarget)
# is called, then a target called target_tsan should be created
# along with target and -fsanitize=thread should be passed when compiling it.
function (psq_test_create_tsan_instrumented_binary)

    function (psq_configure)

        set (SANITIZERS_USE_TSAN ON CACHE BOOL "" FORCE)
        cmake_unit_create_simple_executable (target
                                             GENERATING_FILE
                                             "${_CURRENT_LIST_FILE}")
        psq_sanitizer_add_sanitization_to_target (target)
        cmake_unit_assert_that (target_tsan target_exists)

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that (${BUILD_OUTPUT} file_contents any_line
                                matches_regex
                                "^.*-fsanitize=thread.*target.cpp.*$")
        cmake_unit_assert_that (${BUILD_OUTPUT}
                                file_contents
                                any_line
                                matches_regex
                                "^.*-fsanitize=thread.*target_tsan.*$")

    endfunction ()

    if (SANITIZERS_USE_TSAN)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND psq_configure
                                   VERIFY COMMAND psq_verify)

    endif ()

endfunction ()

# If SANITIZERS_USE_UBSAN is set to ON and include (SanitizeTarget)
# is called, then a target called target_ubsan should be created
# along with target and -fsanitize=undefined should be passed when compiling it.
function (psq_test_create_ubsan_instrumented_binary)

    function (psq_configure)

        set (SANITIZERS_USE_UBSAN ON CACHE BOOL "" FORCE)
        cmake_unit_create_simple_executable (target
                                             GENERATING_FILE
                                             "${_CURRENT_LIST_FILE}")
        psq_sanitizer_add_sanitization_to_target (target)
        cmake_unit_assert_that (target_ubsan target_exists)

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that (${BUILD_OUTPUT} file_contents any_line
                                matches_regex
                                "^.*-fsanitize=undefined.*target.cpp.*$")
        cmake_unit_assert_that (${BUILD_OUTPUT}
                                file_contents
                                any_line
                                matches_regex
                                "^.*-fsanitize=undefined.*target_ubsan.*$")

    endfunction ()

    if (SANITIZERS_USE_UBSAN)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND psq_configure
                                   VERIFY COMMAND psq_verify)

    endif ()

endfunction ()

# If SANITIZERS_USE_MSAN is set to ON and include (SanitizeTarget)
# is called, then a target called target_msan should be created
# along with target and -fsanitize=memory should be passed when compiling it.
function (psq_test_msan_instrumented_binary_tracks_origins)

    function (psq_configure)

        set (SANITIZERS_USE_MSAN ON CACHE BOOL "" FORCE)
        cmake_unit_create_simple_executable (target
                                             GENERATING_FILE
                                             "${_CURRENT_LIST_FILE}")
        psq_sanitizer_add_sanitization_to_target (target)

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        set (ORIGIN_TRACKING_REGEX
             "^.*-fsanitize-memory-track-origins=2.*target.cpp.*$")
        cmake_unit_assert_that (${BUILD_OUTPUT} file_contents any_line
                                matches_regex
                                "${ORIGIN_TRACKING_REGEX}")

    endfunction ()

    if (SANITIZERS_USE_MSAN)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND psq_configure
                                   VERIFY COMMAND psq_verify)

    endif ()

endfunction ()

# If SANITIZERS_USE_ASAN is set to ON and include (SanitizeTarget)
# is called, and psq_sanitizer_add_sanitization_to_target is called with
# NO_ASAN then a target called target_asan should not be created.
function (psq_test_no_asan_flag_disables_creation_of_instrumented_binary)

    function (psq_configure)

        set (SANITIZERS_USE_ASAN OFF CACHE BOOL "" FORCE)
        cmake_unit_create_simple_executable (target
                                             GENERATING_FILE
                                             "${_CURRENT_LIST_FILE}")
        psq_sanitizer_add_sanitization_to_target (target NO_ASAN)
        cmake_unit_assert_that (target_asan not target_exists)

    endfunction ()

    if (SANITIZERS_USE_ASAN)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND psq_configure)

    endif ()

endfunction ()

# If SANITIZERS_USE_ASAN is set to OFF and include (SanitizeTarget)
# is called, then a target called target_asan should not be created.
function (psq_test_no_create_asan_instrumented_binary_on_user_disable)

    function (psq_configure)

        set (SANITIZERS_USE_ASAN OFF CACHE BOOL "" FORCE)
        cmake_unit_create_simple_executable (target
                                             GENERATING_FILE
                                             "${_CURRENT_LIST_FILE}")
        psq_sanitizer_add_sanitization_to_target (target)
        cmake_unit_assert_that (target_asan not target_exists)

    endfunction ()

    if (SANITIZERS_USE_ASAN)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND psq_configure)

    endif ()

endfunction ()

# If SANITIZERS_USE_UBSAN is set to ON and include (SanitizeTarget)
# is called, then a target called target_ubsan should be created
# along with target and -fsanitize=undefined and
# -fno-sanitize-recover should be passed when compiling it.
function (psq_test_ubsan_instrumented_binary_no_recover)

    function (psq_configure)

        set (SANITIZERS_USE_UBSAN ON CACHE BOOL "" FORCE)
        cmake_unit_create_simple_executable (target
                                             GENERATING_FILE
                                             "${_CURRENT_LIST_FILE}")
        psq_sanitizer_add_sanitization_to_target (target)

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        cmake_unit_assert_that (${BUILD_OUTPUT} file_contents any_line
                                matches_regex
                                "^.*-fno-sanitize-recover.*target.cpp.*$")

    endfunction ()

    if (SANITIZERS_USE_UBSAN)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND psq_configure
                                   VERIFY COMMAND psq_verify)

    endif ()

endfunction ()

# If SANITIZERS_USE_UBSAN is set to ON and include (SanitizeTarget)
# is called, then a target called target_ubsan should be created
# along with target and -fsanitize=undefined and
# -fsanitize=unsigned-integer-overflow should be passed when compiling it.
function (psq_test_ubsan_instrumented_binary_unsigned_int_overflow)

    function (psq_configure)

        set (SANITIZERS_USE_UBSAN ON CACHE BOOL "" FORCE)
        cmake_unit_create_simple_executable (target
                                             GENERATING_FILE
                                             "${_CURRENT_LIST_FILE}")
        psq_sanitizer_add_sanitization_to_target (target)

    endfunction ()

    function (psq_verify)

        cmake_unit_get_log_for (INVOKE_BUILD OUTPUT BUILD_OUTPUT)
        set (UNSIGNED_INT_OVERFLOW_REGEX
             "^.*-fsanitize=unsigned-integer-overflow.*target.cpp.*$")
        cmake_unit_assert_that (${BUILD_OUTPUT} file_contents any_line
                                matches_regex
                                "${UNSIGNED_INT_OVERFLOW_REGEX}")

    endfunction ()

    if (SANITIZERS_USE_UBSAN)

        cmake_unit_configure_test (INVOKE_CONFIGURE OPTIONS LANGUAGES C CXX
                                   CONFIGURE COMMAND psq_configure
                                   VERIFY COMMAND psq_verify)

    endif ()

endfunction ()

# Dummy test for Windows, so that there is a test to run.
function (psq_test_sanitizers_not_supported)

    function (psq_configure)
    endfunction ()

    if ("${CMAKE_SYSTEM_NAME}" STREQUAL "Windows")

        cmake_unit_configure_config_only_test (CONFIGURE COMMAND psq_configure)

    endif ()

endfunction ()

cmake_unit_init (NAMESPACE psq
                 COVERAGE_FILES
                 "${CMAKE_CURRENT_LIST_DIR}/SanitizeTarget.cmake")

if (BIICODE)

    add_bii_targets ()

endif ()
