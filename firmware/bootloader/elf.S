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

.equ ELF_CLASS_OFFSET,   0x4
.equ ELF_MACHINE_OFFSET, 0x12
.equ ELF_PHOFF_OFFSET,   0x1C
.equ ELF_PHNUM_OFFSET,   0x2C
.equ ELF_ENTRY_OFFSET,   0x18

.equ ELF_SEGMENT_HEADER_SIZE, 32
.equ ELF_SEGMENT_TYPE_PTLOAD, 1

.equ ELF_CLASS_ELF32, 1
.equ ELF_MACHINE_RISCV, 0xF3

#
# Checks the elf type
#   a0 : address in flash
#
.global check_elf_type
check_elf_type:
  addi sp, sp, -16
  sw   ra, 12(sp)
  sw   s0, 8(sp)
  # local 4 byte buffer at offset 4

  # s0 = address of the elf in flash
  mv   s0, a0

  # Read the elf magic (4 bytes)
  mv   a0, s0     # src
  addi a1, sp, 4  # dst 
  li   a2, 3      # size
  call copy_flash_to_ram

  # Compare the elf magic
  la   t0, elf_magic
  lw   t1, 0(t0)
  lw   t2, 4(sp)
  # Clear the 4th byte
  li   t3, 0xFFFFFF
  and  t1, t1, t3
  and  t2, t2, t3
  bne  t1, t2, _bad_magic

  # Read the elf class
  addi a0, s0, ELF_CLASS_OFFSET
  addi a1, sp, 4
  li   a2, 1
  call copy_flash_to_ram

  # Compare the elf class
  li   t0, ELF_CLASS_ELF32
  mv   t1, x0
  lbu  t1, 4(sp)
  bne  t0, t1, _bad_class

  # Read the elf machine
  addi a0, s0, ELF_MACHINE_OFFSET
  addi a1, sp, 4
  li   a2, 1
  call copy_flash_to_ram

  # Compare the elf class
  li   t0, ELF_MACHINE_RISCV
  mv   t1, x0
  lbu  t1, 4(sp)
  bne  t0, t1, _bad_machine

  # Set the return value
  mv   a0, x0

  j    _check_elf_ret

_bad_magic:
  la   a0, bad_magic_str
  call send_string

  j    _check_elf_ret_bad

_bad_class:
  la   a0, bad_class_str
  call send_string

  j    _check_elf_ret_bad

_bad_machine:
  la   a0, bad_machine_str
  call send_string

_check_elf_ret_bad:
  # Set the return value
  li   a0, 1
_check_elf_ret:
  lw   ra, 12(sp)
  lw   s0, 8(sp)
  addi sp, sp, 16

  ret

#
# Copies the ELF in RAM
#   a0 : address in flash
#
.global load_elf_in_ram
load_elf_in_ram:
  addi sp, sp, -64
  sw   ra, 60(sp)
  sw   s0, 56(sp)
  sw   s1, 52(sp)
  sw   s2, 48(sp)
  # 32 byte array at offset 0(sp) to store a segment header

  # s0 = address of the elf in flash
  mv   s0, a0
  # s1 = number of segments
  mv   s1, x0

  # Read the number of entries in the table
  addi a0, s0, ELF_PHNUM_OFFSET
  mv   a1, sp
  li   a2, 2
  call copy_flash_to_ram
  # Store the number of entries
  mv   s1, x0
  lhu  s1, 0(sp)

  # Read the program header table offset
  addi a0, s0, ELF_PHOFF_OFFSET
  mv   a1, sp
  li   a2, 4
  call copy_flash_to_ram
  # Store the address of the program header table
  lw   t0, 0(sp)
  add  s2, s0, t0

  # s2 = address of the program header table

_read_segment:
  # Read the segment header
  mv   a0, s2
  mv   a1, sp
  li   a2, ELF_SEGMENT_HEADER_SIZE
  call copy_flash_to_ram

  # Skip the copy if the segment is not PT_LOAD
  li   t0, ELF_SEGMENT_TYPE_PTLOAD
  lw   t1, 0(sp) # p_type
  bne  t0, t1, _next_segment

  # Skip if the destination address is not in RAM
  lw   t0, 0x8(sp)  # p_vaddr
  lw   t1, 0x14(sp) # p_memsz
  add  t1, t0, t1   # p_vaddr + p_memsz
  la   t2, __RAM_START__
  la   t3, __RAM_END__
  blt  t0, t2, _segment_not_in_ram
  bgt  t1, t3, _segment_not_in_ram

  # Error if trying to overwrite bootloader
  la   t2, __BOOT_START__
  bge  t0, t2, _bootloader_overwrite
  bgt  t1, t2, _bootloader_overwrite

  # Skip the copy if the segment file size is zero
  lw   t0, 0x10(sp)
  beq  t0, x0, _skip_copy

  # Copy the segment data in RAM
  lw   a0, 0x4(sp)  # p_offset
  add  a0, a0, s0   # base + p_offset
  lw   a1, 0x8(sp)  # p_vaddr
  lw   a2, 0x10(sp) # p_filesz
  call copy_flash_to_ram

_skip_copy:
  # Check if addresses need to be cleared
  lw   t0, 0x14(sp) # p_memsz
  lw   t1, 0x10(sp) # p_filesz
  beq  t0, t1, _next_segment

  # Prepare the clear
  sub  t0, t0, t1  # p_memsz - p_filesz
  lw   t2, 0x8(sp) # p_vaddr
  add  t1, t2, t1  # p_vaddr + p_filesz

_clear_bss:
  # Write zeros (1 instead of 4 as sizes may vary)
  sb   x0, 0(t1)
  
  # Move to next address to clear 
  addi t1, t1, 1
  # Decrement the number of addresses to clear
  addi t0, t0, -1

  # Check if last address to clear
  bne  t0, x0, _clear_bss

  j    _next_segment

_segment_not_in_ram:
  la   a0, segnotinram_str
  call send_string

  mv   a0, s1
  call send_hex

_next_segment:
  # Move to the next segment
  addi s2, s2, ELF_SEGMENT_HEADER_SIZE
  # Decrement the number of segments left
  addi s1, s1, -1
  
  # Check if last segment
  bne  s1, x0, _read_segment

  # Load the return value
  mv   a0, x0

  j    _load_elf_in_ram_ret

_bootloader_overwrite:
  la   a0, bootoverwrite_str
  call send_string
  
  # Load the return value
  li   a0, 1

_load_elf_in_ram_ret:
  lw   ra, 60(sp)
  lw   s0, 56(sp)
  lw   s1, 52(sp)
  lw   s2, 48(sp)
  addi sp, sp, 64

  ret

#
# Returns the elf entry point
#   a0 : address in flash
#
.global get_elf_entry
get_elf_entry:
  addi sp, sp, -16
  sw   ra, 12(sp)
  # 1 byte used as local table at offset 0  

  # Get the entry field
  addi a0, a0, ELF_ENTRY_OFFSET # base + e_entry
  mv   a1, sp
  li   a2, 4
  call copy_flash_to_ram
  
  # Set the return value
  lw   a0, 0(sp)

  lw   ra, 12(sp)
  addi sp, sp, 16
  ret

.align 4

elf_magic: .byte 0x7F, 'E', 'L', 'F'
bad_magic_str: .asciz "\n[BOOT] BAD MAGIC "
bad_class_str: .asciz "\n[BOOT] BAD CLASS "
bad_machine_str: .asciz "\n[BOOT] BAD MACHINE "
segnotinram_str: .asciz "\n[BOOT] WARN SEGMENT NOT IN RAM "
bootoverwrite_str: .asciz "\n[BOOT] ERROR BOOT OVERWRITE "
