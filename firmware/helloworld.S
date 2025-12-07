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

.equ UART_BASE, 0x4000

.equ UART_SR, 0x0
.equ UART_CR, 0x4
.equ UART_RXDR, 0x8
.equ UART_TXDR, 0xC

.equ UART_ACC_INCR_SHIFT, 16
.equ UART_DS_MASK, (1 << 3)
.equ UART_TXE_MASK, (1 << 1)

.equ UART_ACC_INCR, 26
.equ UART_DS, 1

.equ TIMER_BASE, 0x8000
.equ TIMER_TIMEBASE_LOW, 0x0
.equ TIMER_TIMEBASE_HIGH, 0x1

.section .text
.global _start
_start:
  # Configure the UART peripheral
  # x1 = (ACC_INCR << ACC_INCR_SHIFT)
  li    x1, UART_ACC_INCR
  slli  x1, x1, UART_ACC_INCR_SHIFT
  # x2 = DS_MASK
  li    x2, UART_DS_MASK
  # x1 = (ACC_INCR << ACC_INCR_SHIFT) | DS_MASK
  or    x1, x1, x2

  # Write the configuration
  li    x10, UART_BASE
  sw    x1, UART_CR(x10)

_send_string:
  # Load the string address
  # x11 = char ptr
  la    x11, msg
_check_send_ready:
  # Check if a character is ready to send
  lw    x1, UART_SR(x10) 
  andi  x1, x1, UART_TXE_MASK
  # Loop if TXE == 0
  beq   x1, x0, _check_send_ready

_send_char:
  # Load the char to send
  lb    x1, 0(x11)

  # If the string is fully sent, wait 1s
  beq   x1, x0, _wait_1s

  # Give the char to the UART peripheral
  sb    x1, UART_TXDR(x10)

  # Move to the next char
  addi  x11, x11, 1

  j     _check_send_ready

_wait_1s:
  # x12 = ms counter
  li   x12, 1000
  # x13 = TIMER_BASE
  li   x13, TIMER_BASE

_read_timebase:
  lw   x1, TIMER_TIMEBASE_HIGH(x13)
  lw   x2, TIMER_TIMEBASE_LOW(x13)
  lw   x3, TIMER_TIMEBASE_HIGH(x13)

  # If the two HIGH's are not equal, loop
  bne x1, x3, _read_timebase

_compare_timebase:
  lw   x4, TIMER_TIMEBASE_HIGH(x13)
  lw   x5, TIMER_TIMEBASE_LOW(x13)
  lw   x6, TIMER_TIMEBASE_HIGH(x13)

  # If the two HIGH's are not equal, loop
  bne x4, x6, _compare_timebase

  # If the two are equal
  bne x2, x5, _decrement
  bne x3, x6, _decrement 

  # If equal, we wait more
  j   _compare_timebase

_decrement:
  # Decrement the counter
  addi x12, x12, -1

  # Check if zero
  bne  x0, x12, _read_timebase
  
  # Send the next string
  j    _send_string

.align 4

msg:
  .asciz "Hello, World!\n"
