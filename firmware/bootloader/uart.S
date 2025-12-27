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

.equ UART_BASE, 0x40000000

.equ UART_SR, 0x0
.equ UART_CR, 0x4
.equ UART_RXDR, 0x8
.equ UART_TXDR, 0xC

.equ UART_ACC_INCR_SHIFT, 16
.equ UART_DS_MASK, (1 << 3)
.equ UART_TXE_MASK, (1 << 1)

.equ UART_ACC_INCR, 10
.equ UART_DS, 1

.section .text

# 
# Configures the UART peripheral
#
.global configure_uart
configure_uart:
  # Configure the UART peripheral
  # t0 = (ACC_INCR << ACC_INCR_SHIFT)
  li    t0, UART_ACC_INCR
  slli  t0, t0, UART_ACC_INCR_SHIFT
  # t1 = DS_MASK
  li    t1, UART_DS_MASK
  # t0 = (ACC_INCR << ACC_INCR_SHIFT) | DS_MASK
  or    t0, t0, t1

  # Write the configuration
  li    t4, UART_BASE
  sw    t0, UART_CR(t4)

  ret

# 
# Send the provided string
#   a0 : address of the string to send
#
.global send_string
send_string:
  # t4 = UART_BASE
  li  t4, UART_BASE
  # t5 = a0
  mv    t5, a0
_check_send_ready_string:
  # Check if a character is ready to send
  lw    t0, UART_SR(t4) 
  andi  t0, t0, UART_TXE_MASK
  # Loop if TXE == 0
  beq   t0, x0, _check_send_ready_string

_send_char:
  # Load the char to send
  lb    t0, 0(t5)

  # If the string is fully sent return
  beq   t0, x0, _return_send_string

  # Give the char to the UART peripheral
  sb    t0, UART_TXDR(t4)

  # Move to the next char
  addi  t5, t5, 1

  j     _check_send_ready_string
  
_return_send_string:
  ret

# 
# Send hex
#   a0 : byte to send
#
.global send_hex
send_hex:
  # t4 = UART_BASE
  li  t4, UART_BASE

  # Load the byte to send
  mv    t5, a0
  li    t1, 8
_check_send_ready_hex:
  # Check if a character is ready to send
  lw    t0, UART_SR(t4) 
  andi  t0, t0, UART_TXE_MASK
  # Loop if TXE == 0
  beq   t0, x0, _check_send_ready_hex

_convert_chars:
  srli   t6, t5, 28
  andi  t6, t6, 0xF

  # Check if it is digit
  li    t2, 10
  blt   t6, t2, _send_digit 
  
  addi  t6, t6, 7 # (55 - 48 = 7)
_send_digit:
  addi  t6, t6, 48

  sb    t6, UART_TXDR(t4)

  # Move to the next hex char
  slli  t5, t5, 4
  addi  t1, t1, -1

  # If done
  beq   t1, x0, _return_send_hex
  
  j     _check_send_ready_hex
  
_return_send_hex:
  ret
