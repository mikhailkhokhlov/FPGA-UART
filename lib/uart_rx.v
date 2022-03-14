`ifndef _UART_RX_V_
  `define _UART_RX_V_
  
`timescale 1ns / 1ps

module uart_rx(input i_clk25MHz,
               input i_reset,
               input i_rx,
               output o_stop_err,
               output o_valid,
               output [7:0] o_rx_data);
  
  parameter WAIT_FOR_START = 3'b000;
  parameter START_BIT      = 3'b001;
  parameter RECV_DATA      = 3'b010;
  parameter STOP_BIT       = 3'b011;
  parameter SUCCESS        = 3'b100;
  parameter STOP_ERR       = 3'b101;
  
  reg [2:0] reg_state;
  reg [2:0] next_state;
  
  reg [7:0] reg_counter;
  reg [7:0] next_counter;
  
  reg [3:0] reg_bits_counter;
  reg [3:0] next_bits_counter;
  
  reg next_start_bit;
  reg reg_start_bit;
  
  reg next_stop_bit;
  reg reg_stop_bit;
  
  reg reg_data_bit;
  reg next_data_bit;
  
  wire serial_period;
  wire half_serial_period;
  
  wire all_bits_recv;
  
  reg [7:0] reg_rx_data;
  reg [7:0] next_rx_data;
  
  always @(posedge i_clk25MHz, posedge i_reset)
    if (i_reset)
      reg_counter <= 0;
  else
      reg_counter <= next_counter;
  
  always @(posedge i_clk25MHz, posedge i_reset)
    if (i_reset)
      reg_bits_counter <= 3'b0;
    else
      reg_bits_counter <= next_bits_counter;
  
  always @(*)
    begin
      next_bits_counter = reg_bits_counter;
      
      if (reg_state == RECV_DATA)
        next_bits_counter = (serial_period) ? reg_bits_counter + 1 : reg_bits_counter;
      else
        next_bits_counter = 0;
    end
  
  assign all_bits_recv = (reg_bits_counter == 7) ? 1'b1 : 1'b0;
  
  always @(*)
    if (reg_state == WAIT_FOR_START)
      next_counter = (~i_rx) ? 0 : reg_counter;
    else
      next_counter = (serial_period) ? 0 : reg_counter + 1;
 
  assign serial_period      = (reg_counter == 8'd218) ? 1'b1 : 1'b0;
  assign half_serial_period = (reg_counter == 8'd109) ? 1'b1 : 1'b0;
  
  always @(posedge i_clk25MHz, posedge i_reset)
    if (i_reset)
      reg_state <= WAIT_FOR_START;
    else
      reg_state <= next_state;
  
  always @(*)
    begin
      next_state = reg_state;
   
      case (reg_state)
        WAIT_FOR_START:
          next_state = (~i_rx) ? START_BIT : WAIT_FOR_START;
        START_BIT:
          if (serial_period)
            next_state = (reg_start_bit) ? RECV_DATA : WAIT_FOR_START;
        RECV_DATA:
          if (serial_period)
            next_state = (all_bits_recv) ? STOP_BIT : RECV_DATA;
        STOP_BIT:
          if (half_serial_period)
            next_state = (i_rx) ? SUCCESS : STOP_ERR;
        SUCCESS:
          next_state = WAIT_FOR_START;
        STOP_ERR:
          next_state = (i_rx) ? WAIT_FOR_START : STOP_ERR;
      endcase
    end
  
  always @(posedge i_clk25MHz, posedge i_reset)
    if (i_reset)
      begin
        reg_start_bit <= 0;
        reg_stop_bit  <= 0;
        reg_data_bit  <= 0;
      end
    else
      begin
        reg_start_bit <= next_start_bit;
        reg_stop_bit  <= next_stop_bit;
        reg_data_bit  <= next_data_bit;
      end
  
  always @(*)
    begin
      next_start_bit = reg_start_bit;
      next_stop_bit = reg_stop_bit;
      next_data_bit = reg_data_bit;
      
      if (reg_state == START_BIT) 
        next_start_bit = (half_serial_period) ? (~i_rx) : reg_start_bit;
      else
        next_start_bit = 0;
      
      if (reg_state == STOP_BIT)
        next_stop_bit = (half_serial_period) ? i_rx : reg_stop_bit;
      else
        next_stop_bit = 0;
      
      if (reg_state == RECV_DATA)
        next_data_bit = (half_serial_period) ? i_rx : reg_data_bit;
      else
        next_data_bit = 0;
    end
  
  always @(posedge i_clk25MHz, posedge i_reset)
    if (i_reset)
      reg_rx_data <= 8'b0;
    else
      reg_rx_data <= next_rx_data;
  
  always @(*)
    begin
      next_rx_data = reg_rx_data;
      if (reg_state == WAIT_FOR_START)
        next_rx_data = 8'b0;
      
      if (reg_state == RECV_DATA)
        next_rx_data = (serial_period) ? (reg_rx_data | (reg_data_bit << reg_bits_counter)) : reg_rx_data;
    end

  assign o_valid    = (reg_state == SUCCESS)  ? 1'b1 : 1'b0;
  assign o_stop_err = (reg_state == STOP_ERR) ? 1'b1 : 1'b0;
  assign o_rx_data  = (reg_state == SUCCESS)  ? reg_rx_data : 8'b0;

endmodule

`endif /* _UART_RX_V_ */