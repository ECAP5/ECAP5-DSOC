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

module tb_ecap5_dsoc (
  input logic  clk_i,
  input logic  rst_i,

//=================================
  //    UART interface
  
  output logic uart_tx_o,
  input  logic uart_rx_i,
  
  //=================================
  //    LEDs interface

  output logic led0_o,
  output logic led1_o,

  //=================================
  //    Buttons interface

  input logic button0_i,
  input logic button1_i
);

ecap5_dsoc dut (
  .clk_i (clk_i),
  .rst_i (rst_i),

  .uart_tx_o (uart_tx_o),
  .uart_rx_i (uart_rx_i),

  .led0_o (led0_o),
  .led1_o (led1_o),

  .button0_i (button0_i),
  .button1_i (button1_i)
);

endmodule // tb_ecap5_dsoc
