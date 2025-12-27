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

`ifndef CLK_FREQ
  `define CLK_FREQ 24000000
`endif

module ecap5_dsoc (
  input logic  ext_clk_i,

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
  input logic button1_i,

  //=================================
  //    SPI interface

  output logic flash_cs_n,
  output logic flash_mosi_o,
  input  logic flash_miso_i,

  //=================================
  //    Unused peripheral control signals 

  output logic sram_ce_n,
  output logic sdram0_cs_n,
  output logic sdram0_cke,
  output logic sdram1_cs_n,
  output logic sdram1_cke,
  output logic ddr2_cs_n,
  output logic ddr2_cke,
  output logic emmc_rst_n
);

// PLL signals
logic        clk, rst, pll_locked;

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

// timer slave memory bus
logic[31:0]  timer_wb_adr_i;
logic[31:0]  timer_wb_dat_o;
logic[31:0]  timer_wb_dat_i;
logic        timer_wb_we_i;
logic[3:0]   timer_wb_sel_i;
logic        timer_wb_stb_i;
logic        timer_wb_ack_o;
logic        timer_wb_cyc_i;
logic        timer_wb_stall_o;

// flash slave memory bus
logic[31:0]  flash_wb_adr_i;
logic[31:0]  flash_wb_dat_o;
logic[31:0]  flash_wb_dat_i;
logic        flash_wb_we_i;
logic[3:0]   flash_wb_sel_i;
logic        flash_wb_stb_i;
logic        flash_wb_ack_o;
logic        flash_wb_cyc_i;
logic        flash_wb_stall_o;

// flash chip select
logic        flash_clk;
logic        flash_cs;

generated_pll pll_inst (
  .clkin   (ext_clk_i),
  .clkout0  (clk),
  .locked   (pll_locked)
);

ecap5_dproc #(
  // last 4K region for boot
  .BOOT_ADDRESS (32'h19800) 
) core_inst (
  .clk_i (clk),
  .rst_i (rst),

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
  .clk_i (clk),
  .rst_i (rst),

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
  .SIZE (106496), // 208 DP16K
  .ENABLE_PRELOADING (1),
  .PRELOAD_HEX_PATH (`BOOTLOADER_PATH)
) bram_inst (
  .clk_i (clk),
  .rst_i (rst),

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

ecap5_dwbtimer #(
  .CLK_FREQ (`CLK_FREQ)
) timer_inst (
  .clk_i (clk),
  .rst_i (rst),

  .wb_adr_i   (timer_wb_adr_i),
  .wb_dat_o   (timer_wb_dat_o),
  .wb_dat_i   (timer_wb_dat_i),
  .wb_sel_i   (timer_wb_sel_i),
  .wb_we_i    (timer_wb_we_i),
  .wb_stb_i   (timer_wb_stb_i),
  .wb_ack_o   (timer_wb_ack_o),
  .wb_cyc_i   (timer_wb_cyc_i),
  .wb_stall_o (timer_wb_stall_o)
);

ecap5_dwbspi #(
) flash_inst (
  .clk_i (clk),
  .rst_i (rst),

  .wb_adr_i   (flash_wb_adr_i),
  .wb_dat_o   (flash_wb_dat_o),
  .wb_dat_i   (flash_wb_dat_i),
  .wb_sel_i   (flash_wb_sel_i),
  .wb_we_i    (flash_wb_we_i),
  .wb_stb_i   (flash_wb_stb_i),
  .wb_ack_o   (flash_wb_ack_o),
  .wb_cyc_i   (flash_wb_cyc_i),
  .wb_stall_o (flash_wb_stall_o),

  .spi_cs_o   (flash_cs),
  .spi_clk_o  (flash_clk),
  .spi_mosi_o (flash_mosi_o),
  .spi_miso_i (flash_miso_i)
);

// Flash SPI clock mux
`ifndef VERILATOR
  USRMCLK flash_clk_inst (
    .USRMCLKI(flash_clk),
    .USRMCLKTS(1'b0)
  );
`endif

always_comb begin : memory_mapping
  bram_wb_cyc_i = '0;
  bram_wb_adr_i = '0;
  uart_wb_cyc_i = '0;
  uart_wb_adr_i = '0;
  timer_wb_cyc_i = '0;
  timer_wb_adr_i = '0;
  flash_wb_cyc_i = '0;
  flash_wb_adr_i = '0;
  core_wb_dat_i = '0;
  core_wb_ack_i = '0;
  core_wb_stall_i = '0;

  // 00000000 -> 3FFFFFFF = BRAM
  // 40000000 -> 7FFFFFFF = UART
  // 80000000 -> BFFFFFFF = TIMER
  // C0000000 -> FFFFFFFF = FLASH
  case(core_wb_adr_o[31:30])
    2'h0: begin
      bram_wb_cyc_i = core_wb_cyc_o;
      bram_wb_adr_i = {2'b0, core_wb_adr_o[29:0]};
      core_wb_dat_i = bram_wb_dat_o;
      core_wb_ack_i = bram_wb_ack_o;
      core_wb_stall_i = bram_wb_stall_o;
    end
    2'h1: begin
      uart_wb_cyc_i = core_wb_cyc_o;
      uart_wb_adr_i = {2'b0, core_wb_adr_o[29:0]};
      core_wb_dat_i = uart_wb_dat_o;
      core_wb_ack_i = uart_wb_ack_o;
      core_wb_stall_i = uart_wb_stall_o;
    end
    2'h2: begin
      timer_wb_cyc_i = core_wb_cyc_o;
      timer_wb_adr_i = {2'b0, core_wb_adr_o[29:0]};
      core_wb_dat_i = timer_wb_dat_o;
      core_wb_ack_i = timer_wb_ack_o;
      core_wb_stall_i = timer_wb_stall_o;
    end
    2'h3: begin
      flash_wb_cyc_i = core_wb_cyc_o;
      flash_wb_adr_i = {2'b0, core_wb_adr_o[29:0]};
      core_wb_dat_i = flash_wb_dat_o;
      core_wb_ack_i = flash_wb_ack_o;
      core_wb_stall_i = flash_wb_stall_o;
    end
    default: begin end
  endcase

  uart_wb_dat_i = core_wb_dat_o;
  uart_wb_sel_i = core_wb_sel_o;
  uart_wb_we_i = core_wb_we_o;
  uart_wb_stb_i = core_wb_stb_o;

  bram_wb_dat_i = core_wb_dat_o;
  bram_wb_sel_i = core_wb_sel_o;
  bram_wb_we_i = core_wb_we_o;
  bram_wb_stb_i = core_wb_stb_o;

  timer_wb_dat_i = core_wb_dat_o;
  timer_wb_sel_i = core_wb_sel_o;
  timer_wb_we_i = core_wb_we_o;
  timer_wb_stb_i = core_wb_stb_o;

  flash_wb_dat_i = core_wb_dat_o;
  flash_wb_sel_i = core_wb_sel_o;
  flash_wb_we_i = core_wb_we_o;
  flash_wb_stb_i = core_wb_stb_o;
end

assign rst = !pll_locked;

assign flash_cs_n = !flash_cs;

assign sram_ce_n = 1;
assign sdram0_cs_n = 1;
assign sdram0_cke = 0;
assign sdram1_cs_n = 1;
assign sdram1_cke = 0;
assign ddr2_cs_n = 1;
assign ddr2_cke = 0;
assign emmc_rst_n = 0;

endmodule // ecap5_dsoc
