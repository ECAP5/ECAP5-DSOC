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

OUTPUT_ARCH( "riscv" )
ENTRY(_start)
MEMORY
{
  RAM (rwx) : ORIGIN = 0x0, LENGTH = 0x68000
  BOOT (rwx) : ORIGIN = 0x68000-4K, LENGTH = 4K
}
SECTIONS
{
  .text : { 
    *(.text) 
  } > BOOT
}

__BOOT_STACK_TOP__ = ORIGIN(BOOT) + LENGTH(BOOT);

__RAM_START__ = ORIGIN(RAM);
__RAM_END__ = ORIGIN(RAM) + LENGTH(RAM);
