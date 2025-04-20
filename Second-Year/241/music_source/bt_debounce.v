module bt_debounce(
    input            clk,          //ʱ��
    input            rst_n,        //�źţ�����Ч
    input            bt,           //�ⲿ��������
  output             bt_d              
    );

reg [31:0] count;
reg  keyo ;
always @(posedge clk or negedge rst_n) begin 
    if (!rst_n) begin 
        count   <= 32'd0;
		 keyo   <= 1'b0;
    end
    else begin
 
        if(bt == 1'b0)   begin     //������ʼΪ1    
            count <= count + 32'd1;  
			if(count == 32'd1000000)   begin 
                 keyo   <= 1'b1;    
			end	 
             else begin
                 keyo   <= 1'b0;
             end           
		end   
		else
              count   <= 32'd0;
		
	end
end


reg        keyout_d1;
reg        keyout_d0;

always @(posedge clk or negedge rst_n) begin 
    if (!rst_n) begin 
        keyout_d1   <= 1'b0;
        keyout_d0   <= 1'b0;
    end
    else begin
        keyout_d0   <=keyo;
        keyout_d1   <= keyout_d0;
    end   
end

assign  bt_d = keyout_d0 & (~keyout_d1) ;
    
	

	
	
endmodule 