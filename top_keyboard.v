`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:35:57 07/20/2013 
// Design Name: 
// Module Name:    top_module 
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
module top_keyboard	(	clk,
							reset,
							sel,
							ps2d,
							ps2c,
							rx_en,
							IP_Command,
							IP_Angle,
							Nex_Command,
							dout_enter,
							data_temp_disp
						);
//------------INPUT AND OUTPUT LINES----------------------------------
input [1:0] sel;//SELECT LINE
input clk,reset;
input ps2c, ps2d;
input rx_en;	//ENABLE KEYBOARD DATA RECEIVE
output reg [7:0] IP_Command; //FOR SELECTING INPUT DEVICE 
output reg [7:0] Nex_Command; //FOR CONTINUE OR EXIT
output reg 		  dout_enter; //FOR SENSING ENTER KEY PRESSED
output 	  [23:0]data_temp_disp; //FOR ANGLE INPUT DATA
output 	  [8:0] IP_Angle;  //FOR INPUT ANGLE DATA

wire flag;
reg [7:0] dout_temp;
wire [7:0] dout_temp1;
reg [31:0] data;
reg [7:0] BCD_IP1, BCD_IP2, BCD_IP3;
 
assign dout=dout_temp[7:0];

//--------------GET ASCII CODE FROM KEYBOARD------------------------------------
ps2_rx keyboard(	.clk(clk),
						.reset(reset),
						.ps2d(ps2d),
						.ps2c(ps2c),
						.rx_en(rx_en),
						.rx_done_tick(flag),
						.dout(dout_temp1)
					);
					
//--------------PACK THE ASCII CODES INTO DIFFERENT FORMAT------------------
integer counter=0;
parameter [1:0] idle=2'b00, delay = 2'b10, key_val=2'b11;
reg [1:0] state,nextstate=idle;
wire [23:0] data_temp_disp1;
reg  [23:0] data_temp_disp2;

assign data_temp_disp1 = data[23:0];
assign data_temp_disp  = (dout_temp==8'h13)?data_temp_disp2:data_temp_disp1;
always @ (posedge clk)
begin
state=nextstate;
case (state)
	idle:	begin
			dout_temp = 8'b0;
			if (flag==1'b0)
				begin
				nextstate=idle;
				end
			else if (flag==1'b1)
				nextstate=delay;
			else
				nextstate=idle;
			end	
	delay : 	begin
				if (counter==10000000)
					begin
					counter=0;
					nextstate= key_val;
					end
				else
					begin
					nextstate=delay;
					counter=counter+1'b1;									
					end
				end
	key_val : begin
				 dout_temp = dout_temp1;
				 data=((dout_temp==8'h13)||(dout_temp==8'h00)||
						((sel==2'b10)&&((dout_temp==8'h43)||(dout_temp==8'h45)||(dout_temp==8'h4B)||(dout_temp==8'h52))))?data:{data[23:0],dout_temp};
				 nextstate=idle;
				 end
	default : 	begin
					nextstate=idle;
					end
endcase
end

//------------------SENSE ENTER AND ASSIGN SCANCODE OBTAINED INTO DIFFERENT PACKETS-----
always @(posedge clk)
begin
	if(dout_temp == 8'h13)
		begin
			dout_enter = 1'b1;
			case (sel)
				2'b01:IP_Command = data[7:0];
				2'b10:
					begin
						data_temp_disp2= data[23:0];
						BCD_IP1[7:0] 	= data[23:16]- 8'h30;	
						BCD_IP2[7:0] 	= data[15:8]- 8'h30;	
						BCD_IP3[7:0] 	= data[7:0] - 8'h30;	
					end
				2'b11:Nex_Command=data[7:0];
				default:;
			endcase
		end
	else
		dout_enter = 1'b0;
end

//-------------CHANGE ASCII VALUE OBTAINED FOR ANGLE INPUT INTO HEX EQUIVALENT------------
wire [11:0] BCD_IP;
wire [8:0] IP_Angle_To_cordic;//angle value to be sent to cordic not req
wire [11:0] HEX_VAL;
assign BCD_IP[11:0] = {BCD_IP1[3:0], BCD_IP2[3:0], BCD_IP3[3:0]};
assign IP_Angle_To_cordic = HEX_VAL[8:0];//not req
assign IP_Angle = HEX_VAL[8:0];

BCD_to_HEX GETHEX (	.reset(reset),
							.ip(BCD_IP),
							.op(HEX_VAL)
						);

endmodule
