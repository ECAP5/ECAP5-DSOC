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

module ecap5_dsoc (
  input logic  clk_i,

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

// poweron-reset
logic        por_rst;

// core master memory bus
logic[31:0]  core_wb_adr_o;
logic[31:0]  core_wb_dat_i;
logic[31:0]  core_wb_dat_o;
logic        core_wb_we_o;
logic[3:0]   core_wb_sel_o;
logic        core_wb_stb_o;
logic        core_wb_ack_i;
logic        core_wb_cyc_o;
logic        core_wb_stall_i;

// uart slave memory bus
logic[31:0]  uart_wb_adr_i;
logic[31:0]  uart_wb_dat_o;
logic[31:0]  uart_wb_dat_i;
logic        uart_wb_we_i;
logic[3:0]   uart_wb_sel_i;
logic        uart_wb_stb_i;
logic        uart_wb_ack_o;
logic        uart_wb_cyc_i;
logic        uart_wb_stall_o;

// bram slave memory bus
logic[31:0]  bram_wb_adr_i;
logic[31:0]  bram_wb_dat_o;
logic[31:0]  bram_wb_dat_i;
logic        bram_wb_we_i;
logic[3:0]   bram_wb_sel_i;
logic        bram_wb_stb_i;
logic        bram_wb_ack_o;
logic        bram_wb_cyc_i;
logic        bram_wb_stall_o;

poweron_reset por_inst (
  .clk_i (clk_i),
  .rst_o (por_rst)
);

ecap5_dproc #(
  .BOOT_ADDRESS (32'h0)
) core_inst (
  .clk_i (clk_i),
  .rst_i (por_rst),

  .wb_adr_o   (core_wb_adr_o),
  .wb_dat_i   (core_wb_dat_i),
  .wb_dat_o   (core_wb_dat_o),
  .wb_sel_o   (core_wb_sel_o),
  .wb_we_o    (core_wb_we_o),
  .wb_stb_o   (core_wb_stb_o),
  .wb_ack_i   (core_wb_ack_i),
  .wb_cyc_o   (core_wb_cyc_o),
  .wb_stall_i (core_wb_stall_i)
);

ecap5_dwbuart uart_inst (
  .clk_i (clk_i),
  .rst_i (por_rst),

  .wb_adr_i   (uart_wb_adr_i),
  .wb_dat_o   (uart_wb_dat_o),
  .wb_dat_i   (uart_wb_dat_i),
  .wb_sel_i   (uart_wb_sel_i),
  .wb_we_i    (uart_wb_we_i),
  .wb_stb_i   (uart_wb_stb_i),
  .wb_ack_o   (uart_wb_ack_o),
  .wb_cyc_i   (uart_wb_cyc_i),
  .wb_stall_o (uart_wb_stall_o),

  .uart_rx_i (uart_rx_i),
  .uart_tx_o (uart_tx_o)
);

ecap5_dwbmem_bram #(
  .ENABLE_PRELOADING (1),
  .PRELOAD_HEX_PATH ("/tmp/build/firmware/helloworld.load")
) bram_inst (
  .clk_i (clk_i),
  .rst_i (por_rst),

  .wb_adr_i   (bram_wb_adr_i),
  .wb_dat_o   (bram_wb_dat_o),
  .wb_dat_i   (bram_wb_dat_i),
  .wb_sel_i   (bram_wb_sel_i),
  .wb_we_i    (bram_wb_we_i),
  .wb_stb_i   (bram_wb_stb_i),
  .wb_ack_o   (bram_wb_ack_o),
  .wb_cyc_i   (bram_wb_cyc_i),
  .wb_stall_o (bram_wb_stall_o)
);

always_comb begin : memory_mapping
  // 00000000 -> 00004000 = BRAM
  // 00004000 -> 00008000 = UART
  bram_wb_cyc_i = core_wb_cyc_o & ~core_wb_adr_o[14]; 
  bram_wb_adr_i = core_wb_adr_o;
  uart_wb_cyc_i = core_wb_cyc_o &  core_wb_adr_o[14]; 
  uart_wb_adr_i = {core_wb_adr_o[31:15], 1'b0, core_wb_adr_o[13:0]};

  core_wb_dat_i = core_wb_adr_o[14] ? uart_wb_dat_o : bram_wb_dat_o;
  core_wb_ack_i = core_wb_adr_o[14] ? uart_wb_ack_o : bram_wb_ack_o;
  core_wb_stall_i = core_wb_adr_o[14] ? uart_wb_stall_o : bram_wb_stall_o;

  uart_wb_dat_i = core_wb_dat_o;
  uart_wb_sel_i = core_wb_sel_o;
  uart_wb_we_i = core_wb_we_o;
  uart_wb_stb_i = core_wb_stb_o;

  bram_wb_dat_i = core_wb_dat_o;
  bram_wb_sel_i = core_wb_sel_o;
  bram_wb_we_i = core_wb_we_o;
  bram_wb_stb_i = core_wb_stb_o;
end

// TODO: add GPIO peripheral for LED/button interface

endmodule // ecap5_dsoc
