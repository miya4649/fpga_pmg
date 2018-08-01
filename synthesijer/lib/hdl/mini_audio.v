/*
  Copyright (c) 2015-2018, miya
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

// pcm[31:16]: unsigned 16bit pcm R
// pcm[15:0]:  unsigned 16bit pcm L
// FACTOR MUL/DIV: ex. 48kHz/16MHz = 3/1000
// COUNTER_BITS > FACTOR MUL,DIV BITS + 1

module mini_audio
  #(
    parameter COUNTER_BITS = 20
    )
  (
   input                           clk,
   input                           reset,
   input [31:0]                    data,
   input                           valid_toggle,
   input signed [COUNTER_BITS-1:0] ext_factor_mul,
   input signed [COUNTER_BITS-1:0] ext_factor_div,
   output                          full,
   output                          ext_audio_r,
   output                          ext_audio_l
   );

  localparam TRUE = 1'b1;
  localparam FALSE = 1'b0;
  localparam ONE = 1'd1;
  localparam ZERO = 1'd0;
  localparam FIFO_DEPTH_IN_BITS = 4;

  // fifo data write
  wire          we;
  reg           toggle;
  reg           toggle_prev;
  reg [31:0]    data_in;

  assign we = ((toggle_prev != toggle) && (full == FALSE)) ? TRUE : FALSE;

  always @(posedge clk)
    begin
      if (reset == TRUE)
        begin
          toggle <= FALSE;
          data_in <= ZERO;
          toggle_prev <= FALSE;
        end
      else
        begin
          toggle <= valid_toggle;
          data_in <= data;
          toggle_prev <= toggle;
        end
    end

  // fifo data read
  wire          req;
  wire          empty;
  wire          valid;
  reg [15+1:0]  sample_sum_r;
  reg [15+1:0]  sample_sum_l;
  wire [31:0]   data_out;
  reg [31:0]    data_out_reg;

  assign ext_audio_r = sample_sum_r[15+1];
  assign ext_audio_l = sample_sum_l[15+1];

  always @(posedge clk)
    begin
      if (reset == TRUE)
        begin
          data_out_reg <=  ZERO;
        end
      else
        begin
          // read data delays 1 cycle
          if (valid)
            begin
              data_out_reg <= data_out;
            end
        end
    end

  // delta sigma
  always @(posedge clk)
    begin
      if (reset == TRUE)
        begin
          sample_sum_r <= ZERO;
          sample_sum_l <= ZERO;
        end
      else
        begin
          sample_sum_r <= sample_sum_r[15:0] + data_out_reg[31:16];
          sample_sum_l <= sample_sum_l[15:0] + data_out_reg[15:0];
        end
    end

  frac_clk
    #(
      .COUNTER_BITS (COUNTER_BITS)
      )
  frac_clk_0
    (
     .clk (clk),
     .reset (reset),
     .factor_mul (ext_factor_mul),
     .factor_div (ext_factor_div),
     .en (req)
   );

  fifo
    #(
      .WIDTH (32),
      .DEPTH_IN_BITS (FIFO_DEPTH_IN_BITS),
      .MAX_ITEMS ((1 << FIFO_DEPTH_IN_BITS) - 3)
      )
  fifo_0
    (
     .clk (clk),
     .reset (reset),
     .req_r (req),
     .we (we),
     .data_w (data_in),
     .data_r (data_out),
     .valid_r (valid), 
     .full (full),
     .empty (empty)
     );

endmodule
