module MEDIAN #(parameter W = 8) (input [W-1:0] DI, input DSI, input nRST, input CLK, output [W-1:0] DO, output logic DSO);

logic BYP;
enum logic [2:0] {S0, S1, S2, S3, S4} state, n_state;
int tmp;

MED #(.W(W)) med (.DI(DI), .DSI(DSI), .BYP(BYP), .CLK(CLK), .DO(DO));


//Processus de gestion de changement d'éat de l'automate à 5 états
always_comb
begin
	n_state = state;
	case (state)	
	S0 : if (tmp == 8)
		n_state <= S1;	
	S1 : if (tmp == 17)
		n_state <= S2;
	S2 : if (tmp == 26)
		n_state <= S3; 
	S3 : if (tmp == 35)
		n_state <= S4;
	S4 : if (tmp == 39)
		n_state <= S0;	
	endcase
end


//Processus de gestion du compteur tmp et de changement d'état de l'automate
always_ff @(posedge CLK or negedge nRST) 
	if (!nRST) begin
		state <= S0;
		tmp <= 0;
	end
	else
	begin
		state <= n_state;
		if (state == S4  & n_state == S0) 
			tmp <= 0;
		else if (state == S0 & DSI == 0)
			tmp <= tmp + 1;
		else if (state == S0 & DSI == 1)
			tmp <= tmp;
	end

//Processus combinatoire de gestion des signaux BYP et DSO en fonction de
//l'état de l'automate
always_comb
begin
	if (state == S0) begin
		DSO <= 0;
		if(tmp < 8 ) begin
			BYP <= 0; 
		end
		else begin
			BYP <= 1;
		end
	end

	if (state == S1) begin
		DSO <= 0;
		if(tmp < 16 ) begin
			BYP <= 0;
		end
		else begin
			BYP <= 1;
		end
	end

	if (state == S2) begin
		DSO <= 0;
		if(tmp < 24 ) begin
			BYP <= 0;
		end
		else begin
			BYP <= 1;
		end
	end

	if (state == S3) begin
		DSO <= 0;
		if(tmp < 32 ) begin
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
