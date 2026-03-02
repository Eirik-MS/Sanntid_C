# C_heis — Elevator controller (C) + simulator server (D)

This is a C implementation of a distributed elevator controller project comunicating over IPv4
The main controller is written in C and uses a small hardware/IO driver in `Driver/`.
A simulator server (written in D) lives in the subrepository `Server/` and can be built with DMD.
The project is built with CMake and produces binaries in `./bin/`.

To start working type this in the terminal:
```git clone --recurse-submodules git@github.com:Eirik-MS/Sanntid_C.git```

## Prerequisites

Required to build everything:
- [**CMake**](https://cmake.org/download/) (>= 3.16)
- [**GCC**](https://gcc.gnu.org) or other C compiler
- [**DMD** (The D lang compiler)](http://dlang.org/download.html#dmd) to build the simulator server.

## Project structure (high level)

```
C_heis/
├── CMakeLists.txt
├── Driver/                  # C driver + config file + tests
├── Src/                     # Elevator Source files
│   └── main.c
├── Server/                  # D simulator server sources
├── bin/                     # Output binaries (generated)
└── build/                   # Build directory (generated)
```

## Build

Configure + build (default builds app + tests + server if enabled in CMake options):
```sh
cmake -S . -B build
cmake --build build -j
```

### Build options

Enable/disable components at configure time:
```sh
cmake -S . -B build -DBUILD_TESTS=ON  -DBUILD_SERVER=ON
cmake -S . -B build -DBUILD_TESTS=OFF -DBUILD_SERVER=ON
cmake -S . -B build -DBUILD_TESTS=ON  -DBUILD_SERVER=OFF
```

## Run

Binaries are placed in `./bin/`:
- `bin/elevator`
- `bin/elevator_driver_tests` (if `BUILD_TESTS=ON`)
- `bin/SimElevatorServer` (if `BUILD_SERVER=ON`)

You will ned to run `bin/SimElevatorServer` in a separate terminal window before running `elevator`

## Configuration file

The driver reads configuration from:
- `Driver/elevator_hardware.con`

If you run into “Unable to open config file …”, make sure your working directory
and/or your build setup matches how your code references the config path.
