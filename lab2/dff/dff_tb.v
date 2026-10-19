`timescale 1ns/1ps
module diff_sim ();

reg clk;
reg clr;
reg en ;
reg d  ;
wire q;

initial begin
    clr = 1'b1;     // ʼλʼ
    en  = 1'b0;
    clk = 0;
    d   = 0;

    #10;            // д  
    clr = 1'b0;
    en  = 1'b1;
    d   = 1'b1;
    #10 d = 1'b0;
    #10 d = 1'b1;

    #10;            //ȡ
    en = 1'b0;
    d  = 1'b0;

    #10 clr = 1'b1; //첽
    #50 $finish;
end

always #5 clk = ~clk;   //ʱ

dff u_dff(              //ģ
    .clk(clk),
    .clr(clr),
    .en(en),
    .d(d),
    .q(q)
);
endmodule