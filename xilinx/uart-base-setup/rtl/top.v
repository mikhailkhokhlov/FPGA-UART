`timescale 1ns / 1ps

`include "mmcm.v"
`include "areset.v"
`include "pmod_ssd.v"
`include "../../../lib/uart_rx.v"
`include "../../../lib/uart_tx.v"

module top(input i_clock_125MHz,
           input i_uart_rx,
           output o_uart_tx,
           output o_seg_a,
           output o_seg_b,
           output o_seg_c,
           output o_seg_d,
           output o_seg_e,
           output o_seg_f,
           output o_seg_g,
           output o_seg_sel,
           output o_led_tx,
           output o_led_rx);

  wire clock_125MHz;          
  wire clock_25MHz;
  wire reset;
  wire locked;
  
  reg reg_uart_rx1;
  reg reg_uart_rx2;

  wire [7:0] rx_data;
  wire rx_stop_err;
  wire rx_valid;
  reg  [7:0] reg_rx_data1;
  reg  [7:0] reg_rx_data2;
  
  wire tx_ready;
  wire tx_valid;
  wire [7:0] tx_data;
  
  mmcm mmcm0(.i_sys_clock(i_clock_125MHz),
             .o_clock_25MHz(clock_25MHz),
             .o_clock_125MHz(clock_125MHz),
             .o_locked(locked));

  areset areset0(.i_clock(clock_25MHz), .i_launch(locked), .o_reset(reset));
  
  always @(posedge clock_25MHz) begin
    reg_uart_rx1 <= i_uart_rx;
    reg_uart_rx2 <= reg_uart_rx1;
  end

  uart_rx uart_rx0(.i_clk25MHz(clock_25MHz),
                   .i_reset   (reset),
                   .i_rx      (reg_uart_rx2),
                   .o_stop_err(rx_stop_err),
                   .o_valid   (rx_valid),
                   .o_rx_data (rx_data));
                   
  always @(posedge clock_125MHz)
    if (rx_valid)
      reg_rx_data1 <= rx_data;
      
  always @(posedge clock_125MHz)
    reg_rx_data2 <= reg_rx_data1;
    
  pmod_ssd pmod_ssd0(.i_clock_125MHz(clock_125MHz),
                     .i_data        (reg_rx_data2),
                     .o_seg_a       (o_seg_a),
                     .o_seg_b       (o_seg_b),
                     .o_seg_c       (o_seg_c),
                     .o_seg_d       (o_seg_d),
                     .o_seg_e       (o_seg_e),
                     .o_seg_f       (o_seg_f),
                     .o_seg_g       (o_seg_g),
                     .o_seg_sel     (o_seg_sel));

   assign tx_valid = rx_valid;
   assign tx_data  = rx_data;
                     
   uart_tx uart_tx0(.i_clk25MHz(clock_25MHz),
                    .i_reset   (reset),
                    .i_tx_data (tx_data),
                    .i_valid   (tx_valid),
                    .o_tx      (o_uart_tx),
                    .o_ready   (tx_ready));

   assign o_led_tx = ~o_uart_tx;
   assign o_led_rx = ~i_uart_rx;
   
endmodule
