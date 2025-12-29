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

.equ FLASH_MFID,     0xEF
.equ FLASH_DEVTYPE,  0x40
.equ FLASH_SIZE,     0x18

.equ EXE_ADDR, 0x300000

.section .text
.global _start
_start:
  la   sp, __BOOT_STACK_TOP__

  call configure_uart
  call configure_spi

  # Checking the flash ID
  li   a0, FLASH_MFID
  li   a1, FLASH_DEVTYPE
  li   a2, FLASH_SIZE
  call check_flash_id
  bne  a0, x0, _booterr

  # Checking ELF 
  li   a0, EXE_ADDR
  call check_elf_type
  bne  a0, x0, _booterr

  # Loading ELF in RAM
  li   a0, EXE_ADDR
  call load_elf_in_ram
  bne  a0, x0, _booterr

  # Get the ELF entry point
  la   a0, EXE_ADDR
  call get_elf_entry

  # Move the entry to ra
  mv   ra, a0

  # Set the stack pointer
  la   sp, __RAM_END__

  # Clear registers (except x0, ra and sp)
  .irp r, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31
    mv x\r, x0
  .endr
  
  # Jump to ra
  ret

_booterr:
  la   a0, bootfail_str 
  call send_string
_loop: 
  j  _loop

.align 4

bootfail_str: .asciz "\n[BOOT] FAIL\n"
pon_str: .asciz "\n[BOOT] FAIL\n"
