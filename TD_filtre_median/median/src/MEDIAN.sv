module MEDIAN #(parameter W = 8) (input [W-1:0] DI, input DSI, input nRST, input CLK, output [W-1:0] DO, output DSO);

MED #(.W(8)) med (.DI(DI), .DSI(DSI), .BYP(BYP), .CLK(CLK), .DO(DO));

enum logic [2:0] {S0, S1, S2, S3, S4} state, n_state;
logic [3:0] tmp = 0;

always_ff @(posedge CLK or negedge nRST) 
	if (nRST)
		state <= S0 ; 
	
	else
		case (state)	
	       	S0 : if (tmp == 9)
			state <= S1; 
		S1 : if (tmp == 18)
			state <= S2;
	       	S2 : if (tmp == 27)
			state <= S3; 
		S3 : if (tmp == 36)
			state <= S4;
		S4 : if (tmp == 40) begin
			state <= S0;	
		end
		endcase

always_comb
begin
	tmp++;
	if (state == S0) begin
		DSO <= 0;
		while(tmp < 9 ) begin
			BYP <= 0; 
		end
		else begin
			BYP <= 1;
		end
	end

	if (state == S1) begin
		DSO <= 0;
		while(tmp < 17 ) begin
			BYP <= 0;
		end
		else begin
			BYP <= 1;
		end
	end

	if (state == S2) begin
		DSO <= 0;
		while(tmp < 25 ) begin
			BYP <= 0;
		end
		else begin
			BYP <= 1;
		end
	end

	if (state == S2) begin
		DS0 <= 0;
		while(tmp < 34 ) begin
			BYP <= 0;
			end
		else begin
			BYP <= 1;
		end
	end

	if (state == S3) begin
		DS0 <= 0;
		while(tmp < 42 ) begin
			BYP <= 0;
		end
		else begin
			BYP <= 1;
		end
	end

	if (state == S4) begin
		BYP <= 0;
		DSO <= 1;
		tmp = 0;
	end

end
endmodule

