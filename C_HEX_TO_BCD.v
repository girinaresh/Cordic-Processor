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
module C_HEX_TO_BCD(	reset,
							ip,
							op
							);

input reset;
input [21:0] ip;
output [47:0] op;
reg [47:0] op_reg = 48'b0;

reg [47:0] temp = 48'b0;
reg [4:0] count = 5'b0;
assign op = op_reg[47:0];

always @ (ip)
begin
if(reset == 1'b1)
	begin
		count  = 5'b0;
		temp   = 48'b0;
		op_reg = 48'b0;
	end
else
	begin
		if(count == 5'b0)
			temp[47:0] = {26'b0,ip[21:0]};

		for(count = 5'b0; count < 5'd23; count= count+1'b1)
		begin
			temp = temp << 1;
			if(temp[27:24] >= 4'b0101 )
				temp[27:24] = temp[27:24] + 4'b0011;
			if(temp[31:28] >= 4'b0101 )
				temp[31:28] = temp[31:28] + 4'b0011;
			if(temp[35:32] >= 4'b0101 )
				temp[35:32] = temp[35:32] + 4'b0011;
			if(temp[39:36] >= 4'b0101 )
				temp[39:36] = temp[39:36] + 4'b0011;
			if(temp[43:40] >= 4'b0101 )
				temp[43:40] = temp[43:40] + 4'b0011;
			if(temp[47:44] >= 4'b0101 )
				temp[47:44] = temp[47:44] + 4'b0011;
		end
		
		if(count == 5'd23)
			begin
				temp = temp << 1;
				count = 5'b0;
			end
		else ;
		
		op_reg[47:40] 	=  temp[47:44]+8'h30;
		op_reg[39:32]  =  temp[43:40]+8'h30;
		op_reg[31:24]  =  temp[39:36]+8'h30;
		op_reg[23:16] 	=  temp[35:32]+8'h30;
		op_reg[15:8]  	=  temp[31:28]+8'h30;
		op_reg[7:0]   	=  temp[27:24]+8'h30;
	end
end
endmodule

