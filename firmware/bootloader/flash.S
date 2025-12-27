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

.section .text

#
# Checks the flash JEDEC identification
#   a0 : manufacturer id
#   a1 : device type
#   a2 : device size
#
.global check_flash_id
check_flash_id:
  addi sp, sp, -32
  sw   ra, 28(sp)
  sw   s0, 24(sp)
  sw   s1, 20(sp)
  sw   s2, 16(sp)
  sw   s3, 12(sp)
  sw   s4, 8(sp)
  sw   s5, 4(sp)

  # s0 = expected manufacturer id
  mv   s0, a0
  # s1 = expected device id
  mv   s1, a1
  # s2 = expected device size
  mv   s2, a2
  
  call enable_cs

  # send the read Jedec ID command
  li   a0, 0x9F
  call send_spi
  # read the manufacturer id
  li   a0, 0x00
  call send_spi
  mv   s3, a0
  # read the device type
  li   a0, 0x00
  call send_spi
  mv   s4, a0
  # read the device size
  li   a0, 0x00
  call send_spi
  mv   s5, a0

  call disable_cs

  # If the manufacturer id is wrong
  bne  s0, s3, _display_bad
  # If the device type is wrong
  bne  s1, s4, _display_bad
  # If the device size is wrong
  bne  s2, s5, _display_bad

  # set the return value = 0
  mv   a0, x0

  j     _check_flash_id_ret

_display_bad:
  la   a0, badflash_str
  call send_string   

  # display the manufacturer id
  la   a0, mfid_str
  call send_string
  
  mv   a0, s3
  call send_hex

  # display the device type
  la   a0, type_str
  call send_string
  
  mv   a0, s4
  call send_hex

  # display the device size
  la   a0, size_str
  call send_string
  
  mv   a0, s5
  call send_hex

  # set the return value = 1
  li   a0, 1

_check_flash_id_ret:
  lw   ra, 28(sp)
  lw   s0, 24(sp)
  lw   s1, 20(sp)
  lw   s2, 16(sp)
  lw   s3, 12(sp)
  lw   s4, 8(sp)
  lw   s5, 4(sp)
  addi sp, sp, 32

  ret

#
# Copies data from flash to ram
#   a0 : src address in flash
#   a1 : dst address in ram
#   a2 : size in bytes
#
.global copy_flash_to_ram
copy_flash_to_ram:
  addi sp, sp, -16
  sw   ra, 12(sp)
  sw   s0, 8(sp)
  sw   s1, 4(sp)
  sw   s2, 0(sp)

  # s0 = src
  mv  s0, a0
  # s1 = dst
  mv  s1, a1
  # s2 = size
  mv  s2, a2

  call enable_cs

  # send fast read command
  li    a0, 0xB
  call  send_spi
  # send fast read address A23-A16
  srli  a0, s0, 16
  andi  a0, a0, 0xFF
  call  send_spi
  # send fast read address A15-A8
  srli  a0, s0, 8
  andi  a0, a0, 0xFF
  call  send_spi
  # send fast read address A7-A0
  andi  a0, s0, 0xFF
  call  send_spi
  # send dummy byte
  li    a0, 0x00
  call  send_spi
_copy:
  # Load a value from flash
  li    a0, 0x00 
  call  send_spi
  # a0 contains the read value
  sb    a0, 0(s1)

  # Increment the dst
  addi  s1, s1, 1
  # Decrement the size
  addi  s2, s2, -1

  # Check if done
  bne   s2, x0, _copy

_copy_flash_to_ram_ret:
  call disable_cs

  lw    ra, 12(sp)
  lw    s0, 8(sp)
  lw    s1, 4(sp)
  lw    s2, 0(sp)
  addi  sp, sp, 16
  
  ret

.align 4

badflash_str: .asciz "\n[BOOT] BAD FLASH"
mfid_str: .asciz "\n  Manufacturer ID : "
type_str: .asciz "\n  Type :            "
size_str: .asciz "\n  Size :            "
