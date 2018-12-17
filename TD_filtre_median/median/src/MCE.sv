module MCE #(parameter W = 8) 
	(input [W-1:0] A,B,
	output [W-1:0] MAX, MIN);

	assign MAX = A < B ? B :
	       		     A ;

	assign MIN = A < B ? A :
			     B ;

endmodule
