`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:33:11 06/01/2013 
// Design Name: 
// Module Name:    mult 
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
module boothmul(result1,q);
input [9:0] q;
output [31:0] result1;

parameter N=34;
reg [N-1:0] m = 34'b01_0110_1100_0001_0110_1100_0001_0110_1100;

wire [2*N-1:0] resultb;
wire [2*N-1:0] resultc;

reg [N-1:0] q_reg;
reg [2*N:0] result;
reg q_1 = 1'b0;
reg [N-1:0] a;

integer i;

assign resultb = result[2*N:1];
assign resultc = resultb>>9;
assign result1 = resultc[31:0];

always @ (m or q)
	begin
		a=34'b0;
		q_reg={24'b0,q};
		q_1=1'b0;
		result={a,q_reg,q_1};
		for(i=0;i<N;i=i+1)
			begin
				case(result[1:0])
					2'b01:	a=a+m;
					2'b10:	a=a-m;
					default:;					
				endcase
			result={a,q_reg,q_1};
			result={result[2*N],result[2*N:1]};
			a=result[2*N:N+1];
			q_reg=result[N:1];
			q_1=result[0];	
			end
	end
endmodule
