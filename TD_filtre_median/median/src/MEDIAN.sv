module MEDIAN #(parameter W = 8) (input [W-1:0] DI, input DSI, input nRST, input CLK, output [W-1:0] DO, output DSO);

MED #(.W(8)) med (.DI(DI), .DSI(DSI), .BYP(BYP), .CLK(CLK), .DO(DO));

enum logic [2:0] {S0, S1, S2, S3, S4} state, n_state;
int tmp;

//Processus de gestion du compteur tmp
always_ff @(posedge CLK or negedge nRST) 
	if (!nRST)
		tmp <= 0;
	else
	begin
		if (state == S0  & n_state == S4) 
			tmp <= 0;
		else 
			tmp <= tmp + 1;
	end

//Processus de gestion de changement d'éat de l'automate à 5 états
always_ff @(posedge CLK or negedge nRST) 
	if (!nRST)
		state <= S0 ;	
	else begin
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
	end

always_comb
begin
	if (state == S0) begin
		DSO <= 0;
		if(tmp < 9 ) begin
			BYP <= 0; 
		end
		else begin
			BYP <= 1;
		end
	end

	if (state == S1) begin
		DSO <= 0;
		if(tmp < 17 ) begin
			BYP <= 0;
		end
		else begin
			BYP <= 1;
		end
	end

	if (state == S2) begin
		DSO <= 0;
		if(tmp < 25 ) begin
			BYP <= 0;
		end
		else begin
			BYP <= 1;
		end
	end

	if (state == S2) begin
		DSO <= 0;
		if(tmp < 34 ) begin
			BYP <= 0;
			end
		else begin
			BYP <= 1;
		end
	end

	if (state == S3) begin
		DSO <= 0;
		if(tmp < 42 ) begin
			BYP <= 0;
		end
		else begin
			BYP <= 1;
		end
	end

	if (state == S4) begin
		BYP <= 0;
		DSO <= 1;
	end

end
endmodule

