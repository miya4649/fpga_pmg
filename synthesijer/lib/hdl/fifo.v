/*
  Copyright (c) 2017, miya
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 
  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

// Ver.2017/09/19

module fifo
  #(
    parameter WIDTH = 32,
    parameter DEPTH_IN_BITS = 3,
    parameter MAX_ITEMS = 5 // ((1 << DEPTH_IN_BITS) - 3)
    )
  (
   input              clk,
   input              reset,
   input              req_r,
   input              we,
   input [WIDTH-1:0]  data_w,
   output [WIDTH-1:0] data_r,
   output             valid_r, 
   output             full,
   output             empty
   );

  localparam DEPTH = (1 << DEPTH_IN_BITS);
  localparam TRUE = 1'b1;
  localparam FALSE = 1'b0;
  localparam ONE = 1'd1;
  localparam ZERO = 1'd0;

  reg [WIDTH-1:0]     buffer [0:DEPTH-1];
  reg [DEPTH_IN_BITS-1:0] addr_r;
  reg [DEPTH_IN_BITS-1:0] addr_w;
  reg [DEPTH_IN_BITS-1:0] addr_r_next;
  reg [DEPTH_IN_BITS-1:0] addr_w_next;
  wire [DEPTH_IN_BITS-1:0] item_count;

  assign empty = (addr_r == addr_w) ? TRUE : FALSE;
  assign data_r = buffer[addr_r];
  assign item_count = addr_w - addr_r;
  assign full = (item_count > MAX_ITEMS) ? TRUE : FALSE;
  assign valid_r = ((req_r == TRUE) && (empty == FALSE)) ? TRUE : FALSE;

  // read
  always @(posedge clk)
    begin
      if (reset == TRUE)
        begin
          addr_r <= ZERO;
          addr_r_next <= ONE;
        end
      else
        begin
          if ((req_r == TRUE) && (empty == FALSE))
            begin
              addr_r <= addr_r_next;
              addr_r_next <= addr_r_next + ONE;
            end
        end
    end

  // write
  always @(posedge clk)
    begin
      if (reset == TRUE)
        begin
          addr_w <= ZERO;
          addr_w_next <= ONE;
        end
      else
        begin
          if (we)
            begin
              addr_w <= addr_w_next;
              addr_w_next <= addr_w_next + ONE;
              buffer[addr_w] <= data_w;
            end
        end
    end

endmodule
