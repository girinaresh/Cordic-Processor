`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:45:43 04/28/2013 
// Design Name: 
// Module Name:    push_button_test 
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
module push_button_test1(button,clk,press);
input button;
input clk;
output reg press=1'b0;

parameter [1:0] 	wait_for_press=2'b00,
						press_delay=2'b01,
						wait_for_release=2'b10,
						release_delay=2'b11;

reg [1:0] state=wait_for_press;

integer counter=0;

always @(posedge clk)
	begin
	case (state)
		wait_for_press : 	begin
								press=1'b0;
								if (button==1'b1)
								state=press_delay;
								else
								state=wait_for_press;
								end
		press_delay		:	begin
								if (counter==50000)
									begin
									counter=0;
									state=wait_for_release;
									end
								else
									begin
									counter=counter+1;
									state=press_delay;
									end
								end
		wait_for_release: begin
								if (button==1'b0)
									begin
									press=1'b1;
									state=release_delay;
									end
								else
									begin
									state=wait_for_release;
									end
								end
		release_delay	:	begin
								//press=1'b0;
								if (counter==50000)
									begin
									counter=0;
									state=wait_for_press;
									end
								else
									begin
									counter=counter+1;
									state=release_delay;
									end
								end
	endcase	
	end
endmodule
