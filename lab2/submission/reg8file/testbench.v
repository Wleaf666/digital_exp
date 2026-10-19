`timescale 1ns / 1ps


module testbench ();

reg        clk;
reg        clr;
reg        en;
reg  [7:0] d;
reg  [2:0] wsel;
reg  [2:0] rsel;
wire [7:0] q;

//  100MHz ʱӣ 10ns
always #5 clk = ~clk;

initial begin

    clk  = 1'b0;
    clr  = 1'b1;
    en   = 1'b0;
    d    = 8'h00;
    wsel = 3'b000;
    rsel = 3'b000;

    #15;
    clr  = 1'b0; 

    #5;
    en   = 1'b1;
    wsel = 3'd2;
    d    = 8'hA5;

    #10;
    wsel = 3'd5;
    d    = 8'h3C;

    #10;
    en   = 1'b0;
    d    = 8'hFF;
    wsel = 3'd0;


    #10;
    rsel = 3'd2; 

    #10;
    rsel = 3'd5;
    #10;
    rsel = 3'd0; 

    #10;
    rsel = 3'd2; 

    #7; 
    clr  = 1'b1;

    #13;
    clr  = 1'b0; 

    #10;
    rsel = 3'd2;
    #10;
    rsel = 3'd5; 

    #20;
    $finish;
end


reg8file reg8filee (
    .clk (clk),
    .clr (clr),
    .en  (en),
    .d   (d),
    .wsel(wsel),
    .rsel(rsel),
    .q   (q)
);

endmodule
