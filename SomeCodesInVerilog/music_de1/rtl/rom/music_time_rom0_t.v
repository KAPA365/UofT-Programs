module music_time_rom0_t (

	input	[8:0]  address,
	input	  clock,
	output	reg [7:0]  q

) ;



always @(posedge clock)
begin
  case(address)
	9'd0    :   q <=8;
	9'd1    :   q <=6;
	9'd2    :   q <=2;
	9'd3    :   q <=4;
	9'd4    :   q <=2;
	9'd5    :   q <=2;
	9'd6    :   q <=2;	
	9'd7    :   q <=4;
	9'd8    :   q <=4;	
	9'd9    :   q <=2;
	9'd10   :   q <=2;
	9'd11   :   q <=2;
	9'd12   :   q <=2;	
	9'd13   :   q <=2;	
	9'd14   :   q <=16;
	9'd15   :   q <=4;
	9'd16   :   q <=2;
	9'd17   :   q <=2;	
	9'd18   :   q <=4;
	9'd19   :   q <=4;	
	9'd20   :   q <=6;
	9'd21   :   q <=2;
	9'd22   :   q <=4;
	9'd23   :   q <=4;
	9'd24   :   q <=4;
	9'd25   :   q <=4;	
	9'd26   :   q <=2;
	9'd27   :   q <=2;
	9'd28   :   q <=2;
	9'd29   :   q <=2;	
	9'd30   :   q <=16;
	9'd31   :   q <=4;
	9'd32   :   q <=2;
	9'd33   :   q <=4;	
	9'd34   :   q <=4;	
	9'd35   :   q <=2;	
	9'd36   :   q <=2;		
	9'd37   :   q <=4;
	9'd38   :   q <=8;
	9'd39   :   q <=3;
	9'd40   :   q <=1;
	9'd41   :   q <=4;
	9'd42   :   q <=3;
	9'd43   :   q <=1;
	

     default : q <= 8'd0 ;
  endcase
end

endmodule
