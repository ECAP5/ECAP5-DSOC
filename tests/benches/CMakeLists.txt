#           __        _
#  ________/ /  ___ _(_)__  ___
# / __/ __/ _ \/ _ `/ / _ \/ -_)
# \__/\__/_//_/\_,_/_/_//_/\__/
# 
# Copyright (C) Clément Chaine
# This file is part of ECAP5-DSOC <https://github.com/ecap5/ECAP5-DSOC>
# 
# ECAP5-DSOC is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# ECAP5-DSOC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with ECAP5-DSOC.  If not, see <http://www.gnu.org/licenses/>.

# Bench parent directory
set(BENCH_DIR ${CMAKE_CURRENT_SOURCE_DIR}/)
# C++ bench include directory
set(TEST_INCLUDE_DIRS ${ecap5_ecap5_dtestlib_SOURCE_DIR}/include)
# Bench CSV output directory
set(TESTDATA_DIR ${CMAKE_CURRENT_BINARY_DIR}/../)

# Lint
add_lint_target(
  TARGET lint
  LIB    ecap5_dsoc
)

# Generate a mocked pll
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/generated_pll.v
    "module generated_pll(\n"
    "    input clkin,\n"
    "    output clkout0,\n"
    "    output locked\n"
    ");\n"
    "logic locked_q = 1'b0;\n"
    "logic locked_qq;\n"
    "always_ff @(posedge clkin) begin\n"
    "  locked_q <= 1;\n"
    "  locked_qq <= locked_q;\n"
    "end\n"
    "assign clkout0 = clkin;\n"
    "assign locked = locked_qq;\n"
    "endmodule\n"
)
# Create a test interface library
add_library(ecap5_dsoc_tests INTERFACE)
target_sources(ecap5_dsoc_tests INTERFACE
  ${CMAKE_CURRENT_BINARY_DIR}/generated_pll.v
)
target_link_libraries(ecap5_dsoc_tests INTERFACE
  ecap5_dsoc
)

# Add testbenches
add_testbench(
  MODULE            ecap5_dsoc
  LIBS              ecap5_dsoc_tests
  BENCH_DIR         ${BENCH_DIR}
  TESTDATA_DIR      ${TESTDATA_DIR}
  TEST_INCLUDE_DIRS ${TEST_INCLUDE_DIRS}
  DEPENDS           bootloader
  DEFINES           BOOTLOADER_PATH=\\\"${CMAKE_BINARY_DIR}/firmware/bootloader.load\\\"
)

# Main targets
add_custom_target(build DEPENDS ${TEST_BINARIES})
add_custom_target(tests DEPENDS ${TEST_TARGETS})
