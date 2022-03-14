`ifndef _ARESET_V_
  `define _ARESET_V_

`timescale 1ns / 1ps

module areset(input i_clock,
              input i_launch,
              output o_reset);

  reg [3:0] reg_reset = 4'b0000;
   
  always @(posedge i_clock)
    if (i_launch)
      reg_reset <= {reg_reset[2:0], 1'b1};
    else
      reg_reset <= 4'b0000;
    
  assign o_reset = ~(&reg_reset) & i_launch;
              
endmodule

`endif /* _ARESET_V_ */