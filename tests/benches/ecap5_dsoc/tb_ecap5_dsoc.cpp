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

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include <svdpi.h>

#include "Vtb_ecap5_dsoc.h"
#include "testbench.h"
#include "riscv.h"

enum CondId {
  __CondIdEnd
};

class TB_Ecap5_dsoc : public Testbench<Vtb_ecap5_dsoc> {
public:
  void reset() {
    this->n_tick(65535);

    Testbench<Vtb_ecap5_dsoc>::reset();
  }

  void tick() {
    Testbench<Vtb_ecap5_dsoc>::tick();
  }
};

int main(int argc, char ** argv, char ** env) {
  srand(time(NULL));
  Verilated::traceEverOn(true);

  // Check arguments
  bool verbose = parse_verbose(argc, argv);

  TB_Ecap5_dsoc * tb = new TB_Ecap5_dsoc();
  tb->open_trace("waves/ecap5_dsoc.vcd");
  tb->open_testdata("testdata/ecap5_dsoc.csv");
  tb->set_debug_log(verbose);
  tb->init_conditions(__CondIdEnd);
  tb->debug_log = true;

  // 60MHz
  tb->clk_ptr = &tb->core->ext_clk_i;
  tb->clk_period_in_ps = 16667;

  /************************************************************/

  tb->reset();
  // 1ms
  tb->n_tick(600000);

  /************************************************************/

  printf("[ECAP5_DSOC]: ");
  if(tb->success) {
    printf("Done\n");
  } else {
    printf("Failed\n");
  }

  delete tb;
  exit(EXIT_SUCCESS);
}
