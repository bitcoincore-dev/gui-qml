# Fuzzing targets for the QML app backend.
#
# Enable with -DBUILD_FUZZ_TESTS=ON. Requires Clang with libFuzzer support
# (e.g. Homebrew LLVM on macOS, or clang on Ubuntu CI).

if(NOT CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    message(WARNING "Fuzz tests require a Clang compiler; skipping test/fuzz.")
    return()
endif()

# Reuse the Qt components already located by the parent project when available.
if(NOT TARGET Qt6::Core)
    find_package(Qt 6.2 MODULE REQUIRED COMPONENTS Core Gui Network Qml Quick Widgets)
endif()

set(FUZZ_SANITIZERS "fuzzer,address,undefined" CACHE STRING "Sanitizers enabled for fuzz targets")

function(add_fuzz_target name)
    add_executable(${name} ${ARGN})
    target_include_directories(${name} PRIVATE
        ${PROJECT_SOURCE_DIR}
        ${PROJECT_SOURCE_DIR}/bitcoin/src
        ${PROJECT_BINARY_DIR}/bitcoin/src
        ${PROJECT_SOURCE_DIR}/test
        ${PROJECT_SOURCE_DIR}/test/mocks
    )
    target_link_libraries(${name} PRIVATE
        bitcoinqml
        bitcoinqt
        Qt6::Core
        Qt6::Gui
        Qt6::Network
        Qt6::Qml
        Qt6::Quick
        Qt6::Widgets
    )
    target_compile_options(${name} PRIVATE
        -fsanitize=${FUZZ_SANITIZERS}
        -g
        -O1
    )
    target_link_options(${name} PRIVATE
        -fsanitize=${FUZZ_SANITIZERS}
    )
    set_target_properties(${name} PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/test/fuzz
    )
endfunction()

add_fuzz_target(fuzz_bitcoin_uri fuzz_bitcoin_uri.cpp)
add_fuzz_target(fuzz_bitcoin_address fuzz_bitcoin_address.cpp)
add_fuzz_target(fuzz_bitcoin_amount fuzz_bitcoin_amount.cpp)
add_fuzz_target(fuzz_qml_datadir fuzz_qml_datadir.cpp)
add_fuzz_target(fuzz_bitcoin_units fuzz_bitcoin_units.cpp)
add_fuzz_target(fuzz_bitcoin_uri_model fuzz_bitcoin_uri_model.cpp)
add_fuzz_target(fuzz_qml_util fuzz_qml_util.cpp)
add_fuzz_target(fuzz_peerstatsutil fuzz_peerstatsutil.cpp)
add_fuzz_target(fuzz_qrimageprovider fuzz_qrimageprovider.cpp)
add_fuzz_target(fuzz_syncprogresstracker fuzz_syncprogresstracker.cpp)
add_fuzz_target(fuzz_rpc_command_executor fuzz_rpc_command_executor.cpp)
add_fuzz_target(fuzz_onboarding_storage fuzz_onboarding_storage.cpp)
add_fuzz_target(fuzz_bitcoin_address_format fuzz_bitcoin_address_format.cpp)
add_fuzz_target(fuzz_bitcoin_amount_format fuzz_bitcoin_amount_format.cpp)
add_fuzz_target(fuzz_psbtqmlmodel fuzz_psbtqmlmodel.cpp)
add_fuzz_target(fuzz_qml_bitcoinunits_extra fuzz_qml_bitcoinunits_extra.cpp)
add_fuzz_target(fuzz_nodemodel fuzz_nodemodel.cpp)
add_fuzz_target(fuzz_walletqmlmodel fuzz_walletqmlmodel.cpp)
add_fuzz_target(fuzz_paymentrequest fuzz_paymentrequest.cpp)
