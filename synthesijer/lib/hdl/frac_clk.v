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

// factor_mul < factor_div
// COUNTER_BITS > factor_mul,div bits + 1

module frac_clk
  #(
    parameter COUNTER_BITS = 4
    )
  (
   input                           clk,
   input                           reset,
   input signed [COUNTER_BITS-1:0] factor_mul,
   input signed [COUNTER_BITS-1:0] factor_div,
   output reg                      en
   );

  localparam TRUE = 1'b1;
  localparam FALSE = 1'b0;
  localparam ONE = 1'd1;
  localparam ZERO = 1'd0;
  localparam SZERO = 1'sd0;

  // clock counter
  reg signed [COUNTER_BITS-1:0] counter_mul;
  reg signed [COUNTER_BITS-1:0] counter_div;
  always @(posedge clk)
    begin
      if (reset == TRUE)
        begin
          counter_mul <= ZERO;
        end
      else
        begin
          counter_mul <= counter_mul + factor_mul;
        end
    end

  always @(posedge clk)
    begin
      if (reset == TRUE)
        begin
          counter_div <= ZERO;
          en <= FALSE;
        end
      else
        begin
          if (counter_mul - counter_div > SZERO)
            begin
              counter_div <= counter_div + factor_div;
              en <= TRUE;
            end
          else
            begin
              en <= FALSE;
            end
        end
    end

endmodule
