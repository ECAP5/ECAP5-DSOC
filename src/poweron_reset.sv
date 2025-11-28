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

module poweron_reset (
  input logic  clk_i,
  output logic rst_o
);

logic[15:0] counter = '0;
logic rst_internal = 1;

always_ff @(posedge clk_i) begin
  if (counter != '1) begin
    counter <= counter + 1'b1;
    rst_internal <= 1'b1;
  end else begin
    rst_internal <= 1'b0;
  end
end

assign rst_o = rst_internal;

endmodule // poweron_reset
