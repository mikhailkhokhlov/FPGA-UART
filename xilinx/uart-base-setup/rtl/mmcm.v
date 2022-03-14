`ifndef _MMCM_V_
  `define _MMCM_V_

`timescale 1ns / 1ps

module mmcm(input  i_sys_clock,
            output o_clock_25MHz,
            output o_clock_125MHz,
            output o_locked);

  wire sys_clock_ibuf;
  wire sys_clock_bufg;

  IBUF sysclock_ibuf(.I(i_sys_clock),    .O(sys_clock_ibuf));
  BUFG sysclock_bufg(.I(sys_clock_ibuf), .O(sys_clock_bufg));

  wire        clock_25MHz_mmcm;
  wire        locked_int;
  wire        clkfbout;
  wire        clkfbout_bufg;

  MMCME2_ADV #(.BANDWIDTH            ("OPTIMIZED"),
               .CLKOUT4_CASCADE      ("FALSE"),
               .COMPENSATION         ("ZHOLD"),
               .STARTUP_WAIT         ("FALSE"),
               .DIVCLK_DIVIDE        (5),
               .CLKFBOUT_MULT_F      (36.500),
               .CLKFBOUT_PHASE       (0.000),
               .CLKFBOUT_USE_FINE_PS ("FALSE"),
               .CLKOUT0_DIVIDE_F     (36.500),
               .CLKOUT0_PHASE        (0.000),
               .CLKOUT0_DUTY_CYCLE   (0.500),
               .CLKOUT0_USE_FINE_PS  ("FALSE"),
               .CLKIN1_PERIOD        (8.000))
  mmcm2_adv(.CLKFBOUT            (clkfbout),
            .CLKFBOUTB           (),
            .CLKOUT0             (clock_25MHz_mmcm),
            .CLKOUT0B            (),
            .CLKOUT1             (),
            .CLKOUT1B            (),
            .CLKOUT2             (),
            .CLKOUT2B            (),
            .CLKOUT3             (),
            .CLKOUT3B            (),
            .CLKOUT4             (),
            .CLKOUT5             (),
            .CLKOUT6             (),
             // Input clock control
            .CLKFBIN             (clkfbout_bufg),
            .CLKIN1              (sys_clock_bufg),
            .CLKIN2              (1'b0),
             // Tied to always select the primary input clock
            .CLKINSEL            (1'b1),
            // Ports for dynamic reconfiguration
            .DADDR               (7'h0),
            .DCLK                (1'b0),
            .DEN                 (1'b0),
            .DI                  (16'h0),
            .DO                  (),
            .DRDY                (),
            .DWE                 (1'b0),
            // Ports for dynamic phase shift
            .PSCLK               (1'b0),
            .PSEN                (1'b0),
            .PSINCDEC            (1'b0),
            .PSDONE              (),
            // Other control and status signals
            .LOCKED              (locked_int),
            .CLKINSTOPPED        (),
            .CLKFBSTOPPED        (),
            .PWRDWN              (1'b0),
            .RST                 (1'b0));

  BUFG clkf_buf   (.I(clkfbout),         .O(clkfbout_bufg));
  BUFG clkout1_buf(.I(clock_25MHz_mmcm), .O(o_clock_25MHz));
  
  assign o_clock_125MHz = sys_clock_bufg;
  assign o_locked = locked_int;

endmodule

`endif /* _MMCM_V */
