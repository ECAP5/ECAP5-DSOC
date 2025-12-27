/*           __        _
 *  ________/ /  ___ _(_)__  ___
 * / __/ __/ _ \/ _ `/ / _ \/ -_)
 * \__/\__/_//_/\_,_/_/_//_/\__/
 * 
 * Copyright (C) Clément Chaine
 * This file is part of ECAP5-DSOC <https://github.com/ecap5/ECAP5-DSOC>
 *
 * ECAP5-DSOC is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * ECAP5-DSOC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with ECAP5-DSOC.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <stddef.h>
#include <stdint.h>

#define UART_BASE 0x40000000
#define UART_SR_TXE_MASK (1 << 1)

typedef struct {
  volatile uint32_t sr;
  volatile uint32_t cr;
  volatile uint32_t rxdr;
  volatile uint32_t txdr;
} uart_regs_t;

void send_string(char * str) {
  uart_regs_t * uart = (uart_regs_t *)UART_BASE;

  char * c = str;
  while(*c != '\0') {
    // Wait for the uart to be ready
    while(!(uart->sr & UART_SR_TXE_MASK)) {}
    
    uart->txdr = *c;

    c += 1;
  }
}

void main(void) {
  send_string("Hello, World!\n"); 

  while(1);
}
