`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:10:46 07/17/2013 
// Design Name: 
// Module Name:    scan_to_ASCII 
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
module scan_to_ASCII(	clk,
								scan_ip,
								ascii_op		
							);
input clk;
input [7:0] scan_ip;
output reg [7:0] ascii_op;
parameter [7:0]	C 		= 8'H21,
						E 		= 8'H24,
						K 		= 8'H42,
						R 		= 8'H2D,
						ZERO 	= 8'H45,
						ONE 	= 8'H16,
						TWO 	= 8'H1E,
						THREE = 8'H26,
						FOUR 	= 8'H25,
						FIVE 	= 8'H2E,
						SIX 	= 8'H36,
						SEVEN = 8'H3D,
						EIGHT = 8'H3E,
						NINE 	= 8'H46,
						ENTER	= 8'h5A;
always @ (posedge clk)
begin
	case(scan_ip)
		C: ascii_op 		= 8'H43;
		E: ascii_op 		= 8'H45;
		K: ascii_op 		= 8'H4B;
		R: ascii_op 		= 8'H52;
		ZERO: ascii_op 	= 8'H30;
		ONE: ascii_op 		= 8'H31;
		TWO: ascii_op 		= 8'H32;
		THREE: ascii_op	= 8'H33;
		FOUR: ascii_op 	= 8'H34;
		FIVE: ascii_op 	= 8'H35;
		SIX: ascii_op 		= 8'H36;
		SEVEN: ascii_op	= 8'H37;
		EIGHT: ascii_op	= 8'H38;
		NINE: ascii_op 	= 8'H39;
		ENTER:ascii_op 	= 8'H13;
		default:ascii_op 	= 8'H00;
	endcase
end
endmodule
