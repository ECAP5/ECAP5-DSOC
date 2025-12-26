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

set(CROSS_COMPILE riscv64-unknown-elf-)
set(CMAKE_ASM_COMPILER ${CROSS_COMPILE}gcc)
set(CMAKE_AR ${CROSS_COMPILE}ar)
set(CMAKE_ASM_COMPILER ${CROSS_COMPILE}gcc)
set(CMAKE_C_COMPILER ${CROSS_COMPILE}gcc)
set(CMAKE_CXX_COMPILER ${CROSS_COMPILE}g++)

enable_language(ASM)

set(TVM rv32ui) # Target Virtual Machine
set(TE p)       # Target Environment

set(CC_OPTS "-static \
            -mcmodel=medany \
            -fvisibility=hidden \
            -nostdlib \
            -nostartfiles")

add_executable(helloworld.elf ${CMAKE_CURRENT_LIST_DIR}/helloworld/helloworld.S)
set_target_properties(helloworld.elf PROPERTIES COMPILE_FLAGS "${CC_OPTS} -march=rv32g -mabi=ilp32"
  LINK_FLAGS    "${CC_OPTS} -march=rv32g -mabi=ilp32 -T${CMAKE_CURRENT_LIST_DIR}/link.ld")

add_custom_command(
  OUTPUT helloworld.dump
  COMMAND ${CROSS_COMPILE}objdump -d helloworld.elf -Mno-aliases -Mnumeric > helloworld.dump
  DEPENDS helloworld.elf
  VERBATIM)

add_custom_command(
  OUTPUT helloworld.load
  COMMAND ${CROSS_COMPILE}objcopy -O verilog --verilog-data-width=4 helloworld.elf helloworld.load
  COMMAND sed -ie "s/\\(.\\)\\s\\(.\\)/\\1\\n\\2/g" helloworld.load
  DEPENDS helloworld.elf
  VERBATIM)

add_custom_target(helloworld DEPENDS helloworld.dump helloworld.load)


add_executable(bootloader.elf ${CMAKE_CURRENT_LIST_DIR}/bootloader/bootloader.S ${CMAKE_CURRENT_LIST_DIR}/bootloader/uart.S ${CMAKE_CURRENT_LIST_DIR}/bootloader/spi.S)
set_target_properties(bootloader.elf PROPERTIES COMPILE_FLAGS "${CC_OPTS} -march=rv32g -mabi=ilp32"
  LINK_FLAGS    "${CC_OPTS} -march=rv32g -mabi=ilp32 -T${CMAKE_CURRENT_LIST_DIR}/link.ld")

add_custom_command(
  OUTPUT bootloader.dump
  COMMAND ${CROSS_COMPILE}objdump -d bootloader.elf -Mno-aliases -Mnumeric > bootloader.dump
  DEPENDS bootloader.elf
  VERBATIM)

add_custom_command(
  OUTPUT bootloader.load
  COMMAND ${CROSS_COMPILE}objcopy -O verilog --verilog-data-width=4 bootloader.elf bootloader.load
  COMMAND sed -ie "s/\\(.\\)\\s\\(.\\)/\\1\\n\\2/g" bootloader.load
  DEPENDS bootloader.elf
  VERBATIM)

add_custom_target(bootloader DEPENDS bootloader.dump bootloader.load)
