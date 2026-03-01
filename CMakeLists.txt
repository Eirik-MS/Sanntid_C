# Minimum CMake version required
cmake_minimum_required(VERSION 3.10)

# Project name
project(Heis)

# Set C standard
set(CMAKE_C_STANDARD 11)

# Add the Driver directory as a subdirectory (must contain CMakeLists.txt)
add_subdirectory(Driver)

# Create executable from main.c
add_executable(heis Src/main.c)

# Link the driver library to the executable
target_link_libraries(heis PRIVATE driver)