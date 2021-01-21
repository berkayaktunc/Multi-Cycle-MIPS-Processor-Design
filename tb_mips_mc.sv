`timescale 1ns/1ns 
module testbench ();
  reg clk,rst;
  reg [5:0] Opcode_Out;
  mips_mc top_module (clk, rst,Opcode_Out);

  initial begin
    clk=1;
    repeat(810) #20 clk=~clk ;
  end

  initial begin
    rst = 1;
    #100
    rst = 0;
  end
endmodule // test