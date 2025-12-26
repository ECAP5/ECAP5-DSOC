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

.equ SPI_BASE, 0xC0000000

.equ SPI_SR, 0x0
.equ SPI_CR, 0x4
.equ SPI_RXDR, 0x8
.equ SPI_TXDR, 0xC

.equ SPI_PRESCALER_SHIFT, 16
.equ SPI_TXE_MASK, 1

.equ SPI_PRESCALER, 100

.section .text

#
# Configure the SPI peripheral
#
.global configure_spi
configure_spi:
  # Configure the UART peripheral
  # t1 = (PRESCALER << PRESCALER_SHIFT)
  li    t1, SPI_PRESCALER
  slli  t1, t1, SPI_PRESCALER_SHIFT

  # Write the configuration
  li    t4, SPI_BASE
  sw    t1, SPI_CR(t4)

  ret

.global enable_cs
enable_cs:
  li  t4, SPI_BASE

  # Read CR
  lw  t0, SPI_CR(t4)

  # Enable CR
  ori t0, t0, 1

  # Store CR
  sw  t0, SPI_CR(t4)
  
  ret

.global disable_cs
disable_cs:
  li  t4, SPI_BASE

  # Read CR
  lw  t0, SPI_CR(t4)

  # Disable CR
  li  t1, 1
  not t1, t1
  and t0, t0, t1

  # Store CR
  sw  t0, SPI_CR(t4)
  
  ret

#
# Send an SPI command
#   a0 : command to send
# returns the read value
#
.global send_spi
send_spi:
  # t4 = SPI_BASE
  li    t4, SPI_BASE
  # t5 = a0
  mv    t5, a0
_check_send_ready:
  # Check if a command is ready to send
  lw    t1, SPI_SR(t4) 
  andi  t1, t1, SPI_TXE_MASK
  # Loop if TXE == 0
  beq   t1, x0, _check_send_ready

_send_command:
  sb    t5, SPI_TXDR(t4)

_check_send_done:
  # Check if the command is sent
  lw    t1, SPI_SR(t4) 
  andi  t1, t1, SPI_TXE_MASK
  # Loop if TXE == 0
  beq   t1, x0, _check_send_done

_read_response:
  lb    a0, SPI_RXDR(t4)
  andi  a0, a0, 0xFF
  
  ret

