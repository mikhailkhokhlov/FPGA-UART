`timescale 1ns / 1ps

package UartTestPkg;

class UartTestData;
  
  localparam MAX_SIZE = 10;
  
  byte rx_data[MAX_SIZE];
  byte rx_size;
  
  function new();
    rx_size = $urandom_range(MAX_SIZE, 1);
    for (byte i = 0; i < rx_size; i++)
      rx_data[i] = $urandom_range(255, 0);
  endfunction
  
endclass

virtual class UartBaseBFM;
  pure virtual task uartWriteByte(byte rx_byte);
  pure virtual task doSendTest(UartTestData data);
endclass

endpackage

interface UartRx_if(input clk, input reset);
  
  import UartTestPkg::*;
  
  logic rx;
  logic stop_err;
  logic valid;
  logic [7:0] rx_data;
  
  class UartImplBFM extends UartBaseBFM;
    
    task uartWriteByte(byte rx_byte);
      for (byte i = 0; i < 8; i++)
      begin
        rx <= rx_byte[i];
        repeat (218) @(posedge clk);
      end
    endtask
    
    task doSendTest(UartTestData data);
      for (byte i = 0; i < data.rx_size; i++)
        fork
          begin
            rx <= 0;
            repeat (218) @(posedge clk);
          
            uartWriteByte(data.rx_data[i]);
          
            rx <= 1;
            repeat (218) @(posedge clk);
          end
          
          begin
            @(posedge valid);
            $display($time,,"==>> sent byte: 0x%h, got byte: 0x%h", data.rx_data[i], rx_data);
            assert(data.rx_data[i] == rx_data);
          end
        join
    endtask
    
  endclass
  
  UartImplBFM bfm = new;

  modport TestUartSend(input clk,
                       input rx_data,
                       input valid,
                       input stop_err,
                       output rx,
                       import bfm);
endinterface
    
program testUart(UartRx_if.TestUartSend testUartSend);
  
//  import UartTestPkg::*;
  UartTestPkg::UartBaseBFM bfm;
  UartTestPkg::UartTestData data;
  
  initial begin
    
    data = new;
    bfm = testUartSend.bfm;
    
    testUartSend.rx <= 1;
    repeat (50) @(posedge testUartSend.clk);
    
    bfm.doSendTest(data);

    #300 $finish;
  end
  
endprogram

module test_uart_tx_top();
  
  logic clk;
  logic reset;

  UartRx_if uart_rx_if(clk, reset);
  
  testUart test_uart(uart_rx_if.TestUartSend);
  
  uart_rx dut(.i_clk25MHz(uart_rx_if.clk),
              .i_reset   (uart_rx_if.reset),
              .i_rx      (uart_rx_if.rx),
              .o_stop_err(uart_rx_if.stop_err),
              .o_valid   (uart_rx_if.valid),
              .o_rx_data (uart_rx_if.rx_data));
  
  initial begin
    $dumpfile("test_top.vcd");
    $dumpvars(0, dut);
    
    $monitor($time,, "UART Rx state: %d", dut.reg_state);
  end
  
  initial begin
    forever #5 clk = ~clk;
  end
  
  initial begin  
    clk = 0;
    reset = 0;
    reset <= #1 1;
    reset <= #6 0;
  end
  
endmodule
