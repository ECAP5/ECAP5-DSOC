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
.global _start
_start:
  call configure_uart
  call configure_spi
  call enable_cs
  
  la   a0, boot_str
  call send_string

  la   a0, readingflash_str
  call send_string

  li   a0, 0x9F
  call send_spi

  li   a0, 0x00
  call send_spi
  mv   s0, a0

  li   a0, 0x00
  call send_spi
  mv   s1, a0

  li   a0, 0x00
  call send_spi
  mv   s2, a0

  la   a0, mfid_str
  call send_string
  
  mv   a0, s0
  call send_hex

  la   a0, type_str
  call send_string
  
  mv   a0, s1
  call send_hex

  la   a0, size_str
  call send_string
  
  mv   a0, s2
  call send_hex

  call disable_cs

_loop:
  j  _loop

.align 4

boot_str:         .asciz "\n\nBooting..."
readingflash_str: .asciz "\nReading flash..."
mfid_str:         .asciz "\nManufacturer ID : "
type_str:        .asciz "\nType : "
size_str:        .asciz "\nSize : "
