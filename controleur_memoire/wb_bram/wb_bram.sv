//-----------------------------------------------------------------
// Wishbone BlockRAM
//-----------------------------------------------------------------
//
// Le paramètre mem_adr_width doit permettre de déterminer le nombre 
// de mots de la mémoire : (2048 pour mem_adr_width=11)

module wb_bram #(parameter mem_adr_width = 11) (
      // Wishbone interface
      wshb_if.slave wb_s
      );

      logic[3:0][7:0] mem [0: 1 << mem_adr_width];
      logic ack_r, ack_w;

      //Mise à zéro des signaux de répétition et d'erreur
      assign wb_s.rty = 0;
      assign wb_s.err = 0;
      
      //Processus de calcul du ACK
      //ACK en ecriture est combinatoire, l'esclave doit répondre le plus vite
      //possible
      assign ack_w = wb_s.stb & wb_s.we;      
      always_ff @(posedge wb_s.clk) begin
	      ack_r <= wb_s.stb & ~wb_s.we;

	      if (ack_r)
		      ack_r <= 0;
      end
      //On assigne le signal ACK de l'interface en fonction du signal WE
      assign wb_s.ack = wb_s.we ? ack_w : ack_r; 

      //Procesus pour la mémoire synchrone
      always_ff @(posedge wb_s.clk)
      begin
	if (wb_s.we)
	begin
		if(wb_s.sel[0])
			mem[wb_s.adr[12:2]][0] <= wb_s.dat_ms[7:0] ;
		if(wb_s.sel[1])
			mem[wb_s.adr[12:2]][1] <= wb_s.dat_ms[15:8] ;
		if(wb_s.sel[2])
			mem[wb_s.adr[12:2]][2] <= wb_s.dat_ms[23:16] ;
		if(wb_s.sel[3])
			mem[wb_s.adr[12:2]][3] <= wb_s.dat_ms[31:24] ;
	end
	wb_s.dat_sm <= mem[wb_s.adr[12:2]];

	end 
endmodule
