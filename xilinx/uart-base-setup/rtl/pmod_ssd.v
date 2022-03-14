`ifndef _PMOD_SSD_V_
  `define _PMOD_SSD_V_

`timescale 1ns / 1ps

module decoder_hex(input [3:0] i_value,
                   output reg [6:0] o_hex_value);
    
    always @(*)
      casex(i_value)
        4'd0:  o_hex_value = 7'b0111_111;
        4'd1:  o_hex_value = 7'b0000_110;
        4'd2:  o_hex_value = 7'b1011_011;
        4'd3:  o_hex_value = 7'b1001_111;
        4'd4:  o_hex_value = 7'b1100_110;
        4'd5:  o_hex_value = 7'b1101_101;
        4'd6:  o_hex_value = 7'b1111_101;
        4'd7:  o_hex_value = 7'b0000_111;
        4'd8:  o_hex_value = 7'b1111_111;
        4'd9:  o_hex_value = 7'b1101_111;
        4'd10: o_hex_value = 7'b1110_111;
        4'd11: o_hex_value = 7'b1111_100;
        4'd12: o_hex_value = 7'b0111_001;
        4'd13: o_hex_value = 7'b1011_110;
        4'd14: o_hex_value = 7'b1111_001;
        4'd15: o_hex_value = 7'b1110_001;
        default: o_hex_value = 7'b1111_111;
      endcase
endmodule 

module pmod_ssd(input i_clock_125MHz,
                input [7:0] i_data,
                output o_seg_a,
                output o_seg_b,
                output o_seg_c,
                output o_seg_d,
                output o_seg_e,
                output o_seg_f,
                output o_seg_g,
                output o_seg_sel);

    reg [14:0] counter;
    reg reg_seg_sel;
    
    wire [6:0] first_digit;
    wire [6:0] second_digit;
    
    always @(posedge i_clock_125MHz) begin
      counter <= counter + 1;
      
      if (counter == { 15{1'b1} })
        reg_seg_sel <= ~reg_seg_sel;
    end

    decoder_hex(.i_value({i_data[3], i_data[2], i_data[1], i_data[0]}), .o_hex_value(first_digit) );
    decoder_hex(.i_value({i_data[7], i_data[6], i_data[5], i_data[4]}), .o_hex_value(second_digit));
    
    assign {o_seg_g, o_seg_f, o_seg_e, o_seg_d, o_seg_c, o_seg_b, o_seg_a} = (reg_seg_sel) ? second_digit : first_digit;
    assign o_seg_sel = reg_seg_sel;
      
endmodule

`endif /* _PMOD_SSD_V_*/