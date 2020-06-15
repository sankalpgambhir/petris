module tetriminogeneration 
(input reg currentstate [0:9] [0:19], reg [1:0], reg[7:0] tetrimino, 
output reg newstate [0:9]) [0:19], ); 

reg activestate [0:9][0:19];
 initial begin
     activestate <= currentstate;
 end

   
   case(tetrimino) begin
       
       3'b000 : begin //straight
           activestate[0][5] <= 1'b1;
           activestate[1][5] <= 1'b1;
           activestate[2][5] <= 1'b1;
           activestate[3][5] <= 1'b1;
       end
       3'b001: begin   //L-Shaped 
           activestate[0][5] <= 1'b1;
           activestate[1][5] <= 1'b1;
           activestate[2][5] <= 


   end 









                                  

