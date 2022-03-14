`ifndef _UART_TX_V_
  `define _UART_TX_V_

`timescale 1ns / 1ps

module uart_tx(input i_clk25MHz,
               input i_reset,
               input [7:0] i_tx_data,
               input i_valid,
               output o_tx,
               output o_ready);
  
  parameter IDLE      = 2'b00;
  parameter START_BIT = 2'b01;
  parameter SEND      = 2'b10;
  parameter STOP_BIT  = 2'b11;
  
  reg [1:0] next_state;
  reg [1:0] reg_state;
  
  reg [3:0] reg_bits_counter;
  reg [3:0] next_bits_counter;
  
  reg [7:0] reg_counter;
  reg [7:0] next_counter;
  
  reg [7:0] reg_tx_data;
  reg [7:0] next_tx_data;
  
  reg reg_tx;
  reg next_tx;
  
  wire end_of_serial_period;
  
  always @(posedge i_clk25MHz, posedge i_reset)
    if (i_reset)
      reg_state <= IDLE;
    else
      reg_state <= next_state;
  
  assign end_of_serial_period = (reg_counter == 8'd218) ? 1'b1 : 1'b0;
  
  always @(*)
    case (reg_state)
      IDLE:
        next_state = (i_valid) ? START_BIT : IDLE;
      START_BIT:
        next_state = (end_of_serial_period) ? SEND : START_BIT;
      SEND:
        next_state = ((reg_bits_counter == 7) & end_of_serial_period) ? STOP_BIT : SEND;
      STOP_BIT:
        next_state = (end_of_serial_period) ? IDLE : STOP_BIT;
    endcase
  
  always @(posedge i_clk25MHz, posedge i_reset)
    if (i_reset)
      begin
        reg_bits_counter <= 0;
        reg_tx_data      <= 0;
        reg_counter      <= 0;
      end
    else
      begin
        reg_bits_counter <= next_bits_counter;
        reg_tx_data      <= next_tx_data;
        reg_counter      <= next_counter;
      end
  
  always @(*)
    begin
      next_bits_counter = reg_bits_counter;
      next_tx_data = reg_tx_data;
      next_counter = reg_counter;
      
      case (reg_state)
        IDLE:
          begin
            next_bits_counter = 0;
            if (i_valid)
              begin
                next_tx_data = i_tx_data;
                next_counter = 8'b0000_0000;
              end
          end
        START_BIT:
          next_counter = reg_counter + 1;
        SEND:
          begin
            next_counter = reg_counter + 1;
            if (end_of_serial_period)
              begin
                next_counter = 8'b0000_0000;
                next_bits_counter = reg_bits_counter + 1;
              end
          end
        STOP_BIT:
          if (end_of_serial_period)
            next_counter = 8'b0000_0000;
          else
            next_counter = reg_counter + 1;
      endcase
    end
  
  always @(posedge i_clk25MHz, posedge i_reset)
    if (i_reset)
      reg_tx <= 1'b1;
    else
      reg_tx <= next_tx;
 
  always @(*)
    if (reg_state == IDLE)
      next_tx = 1'b1;
    else if (reg_state == START_BIT)
      next_tx = 1'b0;
    else if (reg_state == SEND)
      next_tx = reg_tx_data[reg_bits_counter];
    else if (reg_state == STOP_BIT)
      next_tx = 1'b1;
    else
      next_tx = reg_tx;
  
  assign o_tx = reg_tx;
  assign o_ready = (reg_state == IDLE) ? 1'b1 : 1'b0;
  
endmodule

`endif /* _UART_TX_V_ */