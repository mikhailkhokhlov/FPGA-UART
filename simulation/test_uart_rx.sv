`timescale 1ns / 1ps

program test_UartRx(input logic clk,
                    input logic ready,
                    output logic valid);
  
  initial begin
    valid = 0;
    
    @(posedge ready);
    repeat (50) @(posedge clk);
  
    valid = 1;
    #10;
    valid = 0;
    
    repeat (250) @(posedge clk);
    
    @(posedge ready)
    #300;
  
    $finish;
  end
  
endprogram

module test_uart_rx_top();
  
  logic clk;
  logic reset;
  logic valid;
  logic [7:0] tx_data;
  logic ready;
  logic tx;
  
  test_UartRx(.*);
  
  uart_tx dut(.i_clk25MHz(clk),
              .i_reset(reset),
              .i_tx_data(tx_data),
              .i_valid(valid),
              .o_tx(tx),
              .o_ready(ready));
  
  initial begin
    $dumpfile("test_top.vcd");
    $dumpvars(0, dut);
    
    $monitor($time,, "UART Tx state: %d, Valid: %d, Tx line: %d", dut.reg_state, valid, dut.reg_tx);
  end
  
  initial begin
    forever #5 clk = ~clk;
  end
  
  initial begin
    clk = 0;
    reset = 0;
    tx_data = 8'b1010_1010;
    
    reset <= #1 1;
    reset <= #6 0;
  end;
endmodule
