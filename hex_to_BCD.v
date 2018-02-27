`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:03:28 07/22/2013 
// Design Name: 
// Module Name:    hex_to_BCD 
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
module hex_to_BCD(	reset,
							ip,
							op
							);

input reset;
input [11:0] ip;
output [23:0] op;
reg [23:0] op_reg = 24'b0;

reg [23:0] temp = 24'b0;
reg[3:0] count = 4'b0;
assign op = op_reg[23:0];

always @ (ip)
begin
if(reset == 1'b1)
	begin
		count = 4'b0;
		temp = 24'b0;
		op_reg = 24'b0;
	end
else
	begin
		if(count == 4'b0)
			temp[23:0] = {temp[11:0],ip[11:0]};

		for(count = 4'b0; count<4'd11; count= count+1'b1)
		begin
			temp = temp << 1;
			if(temp[15:12] >= 4'b0101 )
				temp[15:12] = temp[15:12] + 4'b0011;
			if(temp[19:16] >= 4'b0101 )
				temp[19:16] = temp[19:16] + 4'b0011;
			if(temp[23:20] >= 4'b0101 )
				temp[23:20] = temp[23:20] + 4'b0011;
		end
		
		if(count == 4'b1011)
			begin
				temp = temp << 1;
				count = 4'b0;
			end
		else ;
		
		op_reg[23:16] =  temp[23:20]+8'h30;
		op_reg[15:8]  =  temp[19:16]+8'h30;
		op_reg[7:0]   =  temp[15:12]+8'h30;
	end
end
endmodule

