cmake_minimum_required(VERSION 3.16)
project(Elevator C D)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)


#------------------------------------
# --------- Build options -----------
#------------------------------------
option(BUILD_TESTS "Build driver tests" ON)
option(BUILD_SERVER "Build the D sim server" ON)
option(BUILD_HALL_ASSIGNER "Build D hall request assigner and link into C app" ON)

#Find dmd for building the D server and hall request assigner
find_program(D_COMPILER NAMES ldc2 dmd)
if (NOT D_COMPILER)
  message(FATAL_ERROR
    "BUILD_HALL_ASSIGNER is ON, but 'dmd' was not found in PATH.\n"
    "Install DMD: http://dlang.org/download.html#dmd\n")
endif()


# Put executables in the project root (./)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/bin)
file(MAKE_DIRECTORY "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")

# Build the driver as a library so both app and tests can link it
add_library(elevator_driver
    Driver/elevator_hardware.c
)
target_include_directories(elevator_driver PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/Driver
    ${CMAKE_CURRENT_SOURCE_DIR}/Src/lib
)

# Main program (built by default)
add_executable(elevator_app
    Src/main.c
)
target_link_libraries(elevator_app PRIVATE elevator_driver)


# ------------------------------------
# -------- Driver TEST build ---------
# ------------------------------------
if (BUILD_TESTS)
    enable_testing()

    add_executable(elevator_driver_tests
        Driver/elevator_hardware_test.c
    )
    target_link_libraries(elevator_driver_tests PRIVATE elevator_driver)

    add_test(NAME elevator_driver_tests COMMAND elevator_driver_tests)
endif()


# ------------------------------------
# ------- D server build (DMD) -------
# ------------------------------------
if (BUILD_SERVER)
  # Find or make the folderstructure needed for compiling the D server
  set(SERVER_SRC_DIR "${CMAKE_CURRENT_SOURCE_DIR}/Server/src")
  set(BIN_DIR ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
  set(SERVER_OUT "${BIN_DIR}/SimElevatorServer")
  set(DOBJ_DIR "${CMAKE_BINARY_DIR}/dobj")
  file(MAKE_DIRECTORY "${DOBJ_DIR}")
  file(MAKE_DIRECTORY "${BIN_DIR}")


  set(SERVER_D_SOURCES
    "${SERVER_SRC_DIR}/sim_server.d"
    "${SERVER_SRC_DIR}/timer_event.d"
  )

  # Build the D server
  add_custom_command(
    OUTPUT "${SERVER_OUT}"
    COMMAND ${D_COMPILER} -w -g
            "sim_server.d" "timer_event.d"
            -od=${DOBJ_DIR}
            -of=${SERVER_OUT}
    DEPENDS ${SERVER_D_SOURCES}
    WORKING_DIRECTORY "${SERVER_SRC_DIR}"
    COMMENT "Building SimElevatorServer with dmd"
    VERBATIM
  )

  add_custom_target(SimElevatorServerTarget ALL
    DEPENDS "${SERVER_OUT}"
  )
endif()


#-------------------------------------
# --- D assigner build and linking ---
#-------------------------------------
if (BUILD_HALL_ASSIGNER)

  set(HRA_DIR "${CMAKE_CURRENT_SOURCE_DIR}/Resources/cost_fns/hall_request_assigner/")
  set(BRIDGE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/Src/lib")

  set(DOBJ_DIR "${CMAKE_BINARY_DIR}/dobj_hra")
  file(MAKE_DIRECTORY "${DOBJ_DIR}")

  set(HRA_LIB "${CMAKE_BINARY_DIR}/libhall_request_assigner.a")

  # D modules needed by your standalone command (EXCEPT main.d)
  set(HRA_D_SOURCES
    "${HRA_DIR}/config.d"
    "${HRA_DIR}/elevator_algorithm.d"
    "${HRA_DIR}/elevator_state.d"
    "${HRA_DIR}/optimal_hall_requests.d"
    "${HRA_DIR}/d-json/jsonx.d"
    "${BRIDGE_DIR}/assigner_bridge.d"
  )

  #/Resources/cost_fns/hall_request_assigner/config.d
  # Resources/cost_fns/hall_request_assigner/config.d
  # Build a static library in one go (no wildcard *.o needed)
  add_custom_command(
    OUTPUT "${HRA_LIB}"
    COMMAND "${D_COMPILER}" -lib -c -w -g
            -od=${DOBJ_DIR}
            -I=${HRA_DIR}
            -I=${HRA_DIR}/d-json
            -I=${BRIDGE_DIR}
            -of=${HRA_LIB}
            ${HRA_D_SOURCES}
    DEPENDS ${HRA_D_SOURCES}
    WORKING_DIRECTORY "${HRA_DIR}"
    COMMENT "Building D hall_request_assigner static library"
    VERBATIM
  )

  add_custom_target(hall_request_assigner_lib DEPENDS "${HRA_LIB}")
  add_dependencies(elevator_app hall_request_assigner_lib)

  target_link_libraries(elevator_app PRIVATE "${HRA_LIB}")

  set_target_properties(elevator_app PROPERTIES
    LINKER_LANGUAGE D
    LINK_EXECUTABLE
      "${D_COMPILER} <LINK_FLAGS> <OBJECTS> -of<TARGET> <LINK_LIBRARIES>"
  )

  #target_include_directories(elevator_app PRIVATE "${BRIDGE_DIR}")

  # Link D runtime + phobos (needed when you link D code into a C executable)
  #target_link_libraries(elevator_app PRIVATE phobos2 druntime pthread m rt dl)
endif()