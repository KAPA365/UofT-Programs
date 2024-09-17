module music_rom0_t (

	input	[8:0]  address,
	input	  clock,
	output	reg [7:0]  q

) ;



always @(posedge clock)
begin
  case(address)
	9'd0    :   q<=8'h13;
	9'd1    :   q<=8'h15;
	9'd2    :   q<=8'h16;
	9'd3    :   q<=8'h21;
	9'd4    :   q<=8'h22;
	9'd5    :   q<=8'h16;
	9'd6    :   q<=8'h21;
	9'd7    :   q<=8'h15;
	9'd8    :   q<=8'h25;
	9'd9    :   q<=8'h31;
	9'd10   :   q<=8'h26;
	9'd11   :   q<=8'h25;
	9'd12   :   q<=8'h23;
	9'd13   :   q<=8'h25;
	9'd14   :   q<=8'h22;
	9'd15   :   q<=8'h22;
	9'd16   :   q<=8'h22;	
	9'd17   :   q<=8'h23;
	9'd18   :   q<=8'h17;
	9'd19   :   q<=8'h16;
	9'd20   :   q<=8'h15;
	9'd21   :   q<=8'h16;
	9'd22   :   q<=8'h21;
	9'd23   :   q<=8'h22;
	9'd24   :   q<=8'h13;
	9'd25   :   q<=8'h21;
	9'd26   :   q<=8'h16;
	9'd27   :   q<=8'h15;
	9'd28   :   q<=8'h16;
	9'd29   :   q<=8'h21;
	9'd30   :   q<=8'h15;
	9'd31   :   q<=8'h23;
	9'd32   :   q<=8'h25;
	9'd33   :   q<=8'h17;
	9'd34   :   q<=8'h22;
	9'd35   :   q<=8'h16;
	9'd36   :   q<=8'h21;

     default : q <= 8'd0 ;
  endcase
end

endmodule
