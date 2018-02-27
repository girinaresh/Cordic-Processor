`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:48:51 07/12/2013 
// Design Name: 
// Module Name:    rotary_encoder 
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
module rotary_encoder	(	clk,
									reset,
									rotory_dev_on,
									rotary_a, 
									rotary_b, 
									rotary_press, 
									counted_value, 
									counted_disp,
									press
									);

input clk,reset,rotory_dev_on;
input rotary_a, rotary_b, rotary_press;
output press;
output  [23:0] counted_disp;
output reg signed [8:0] counted_value = 9'b0;
//reg [1:0] rot = 2'b00;

reg [9:0] counted_reg= 10'b0;
wire    [11:0] counted_disp_wire;
reg     [11:0] counted_disp_reg = 12'b0;

assign counted_disp_wire = counted_disp_reg;

reg delay_rotary ;													//kept for waiting delay
reg rotary_dir, rotary_event;									// rotary_event = high if rotary_a=1 & rotary_b=1, high means counter increase 
reg signed [9:0] counter	= 10'b11_1110_1110;							// rotary_dir = high if rotary_a=0 & rotary_b=1,  																		//	high means left rotate and low means right rotate 																						
reg [9:0]temp;
//-----------------------------------------------------
push_button_test1 PRESS_ROTATE(.button(rotary_press),
										 .clk(clk),
										 .press(press)
										 );
hex_to_BCD		HEX_CONV_BCD(	.reset(reset),
										.ip(counted_disp_wire),
										.op(counted_disp)
										);
//-------------------------------------------------------
//always@(posedge clk)
//begin
//	rot = {rotary_b,rotary_a};
//end
//
always @ (posedge clk)
begin
	case({rotary_b,rotary_a})
	2'b00:begin	rotary_event <= 1'b0;			
					rotary_dir <= rotary_dir; 
			end
	2'b01:begin	
					rotary_event <= rotary_event;		
					rotary_dir <= 1'b0;
			end
	2'b10:begin 
					rotary_event <= rotary_event;		
					rotary_dir <= 1'b1; 
			end
	2'b11:begin 
					rotary_event <= 1'b1;			
					rotary_dir <= rotary_dir; 
			end
	default:begin
					rotary_event <= rotary_event;
					rotary_dir <= rotary_dir;
				end
	endcase
end

always @(posedge clk)
begin
	if(reset == 1'b1)
		begin
			counter = 10'b0;
			temp = 10'b0;
		end
	else
		begin
			delay_rotary <= rotary_event;
			if ((rotary_event == 1'b1) && (delay_rotary == 1'b0))
					begin
						  if(rotary_dir == 1'b1)
								counter = counter - 5'b10010;
			
						  else if(rotary_dir == 1'b0)
								counter = counter + 5'b10010;

						  else;
						  
						  temp = counter;
						  if(counter[9] == 1'b1)
							begin 
								counter = ~counter + 1'b1;
						  end
						  
						  if(counter[9:0] >= 10'b0101101000)
								counter = 10'b0;
						  else 
								counter = temp;
					end
			 else;						
		end
end

always @ (posedge clk)
begin
	if(reset == 1'b1)
		begin
			counted_reg = 10'b0;
			counted_value = 9'b0;
			counted_disp_reg = 12'b0;
		end
	
	else
		begin
			if(press == 1'b1)
				begin
				if(counter[9] == 1'b1)
					begin
						counted_reg = counter + 360;	// to take 2's complement for negative angle
						counted_value = counted_reg[8:0];
					end
				else
					counted_value = counter[8:0];
					
				counted_disp_reg = counted_value;	
			end
			
			else
				begin
				if(counter[9] == 1'b1)
					begin
						counted_disp_reg = counter + 360;	// to take 2's complement for negative angle
					end
				else
					counted_disp_reg = counter;	
			end
		end
end 
endmodule 