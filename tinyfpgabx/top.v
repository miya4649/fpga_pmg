/*
  Copyright (c) 2018, miya
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 
  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

`default_nettype none

module top
  (
   input  clk,
   output usbpu,
   output led,
   output pin12,
   output pin13
   );

  localparam AUDIO_FACTOR_MUL = 3;
  localparam AUDIO_FACTOR_DIV = 1000;

  assign usbpu = 1'b0;

  // soft reset
  parameter RESET_TIMER_BIT = 22;
  reg           reset = 1'b0;
  reg [31:0]    reset_counter = 32'd0;
  always @(posedge clk)
    begin
      if (reset_counter[RESET_TIMER_BIT] == 1'b1)
        begin
          reset <= 1'b0;
        end
      else
        begin
          reset <= 1'b1;
          reset_counter <= reset_counter + 1'd1;
        end
    end

  Composer Composer_0
    (
     .clk (clk),
     .reset (reset),
     .led_in (1'b0),
     .led_we (1'b0),
     .led_out (led),

     .audio_obj_ext_factor_mul_exp (AUDIO_FACTOR_MUL),
     .audio_obj_ext_factor_div_exp (AUDIO_FACTOR_DIV),
     .audio_obj_ext_audio_r_exp (pin13),
     .audio_obj_ext_audio_l_exp (pin12)
     );

endmodule
