`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:40:28 07/27/2013 
// Design Name: 
// Module Name:    Cordic_Handler 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Cordic_Handler(		clk,
									angle_ip,
									Xout,
									Yout
    );
	 
input clk;
input [8:0] angle_ip;
output wire [47:0] Xout,Yout;

wire [21:0] Xout_hex,Yout_hex;
wire [31:0] phase_step;
boothmul FIND32_BIT (	.result1(phase_step),
								.q(angle_ip)
								);

kordic CORDIC  (	.clock(clk), 
						.phase_step(phase_step), 
						.Xout(Xout_hex), 
						.Yout(Yout_hex)
						);


C_HEX_TO_BCD GETBCD_X (.reset(1'b0),
							.ip(Xout_hex),
							.op(Xout)
							);

C_HEX_TO_BCD GETBCD_Y (.reset(1'b0),
							.ip(Yout_hex),
							.op(Yout)
						);


endmodule
