module tetriminogeneration (input wire [3:0] operation , input wire vsync, input reg [9:0] framenumber, output reg currentstate[0:9][0:19], output reg[7:0] score ); 

reg [4:0] centerofmass [0:1][0:3]; //[0][i] represents the x coordinates [1][i] represents the y coordinates
reg [4:0] prevcenterofmass [0:1][0:3];
reg [4:0] tempcoords [0:1][0:3];
reg[3:0] gameover;
reg coloumnvalue;
reg rowvalue;
reg [3:0] state;
integer i,j,k;
reg[4:0] gameclk = 0;
reg[2:0] clk = 0;
wire driver = clk[2];
parameter straight=3'b000;
parameter L=3'b001;
parameter LEn=3'b010;
parameter Skew = 3'b011;
parameter SkewEn=3'b100;
parameter Block=3'b101;
parameter T=3'b110;

parameter stop = 0;
parameter start = 1;
parameter standby = 6;
parameter generator = 2;
parameter testfalldown = 3;
parameter testgameover = 4;
parameter rowdeletion = 5;
parameter testleft = 7;
parameter testright = 8;
parameter update = 9;

// ==================
parameter testrotate = 10;


//Frame buffering to be done later
//always @( posedge vsync) begin
  //  clk <= clk+1;
  //  gameclk <= gameclk +1;
//end

always @(posedge vsync) begin
     gameclk <= gameclk +1;

    case (state) 
        default : begin
            tetrimino <= 0;
            prevtetrimino <= 0;
            for(i=0;i<2;i=i+1) begin
                for(j = 0;j<4;j=j+1) begin
                    centerofmass[i][j] <= 0;
                    prevcenterofmass[i][j] <= 0;
                end
            end

            for (i=0; i<10; i=i+1) begin //Assign the gameboard = 0;
                for (j = 0; j<20; j=j+1) begin
                    currentstate[i][j] <= 0;
                end
            end
            score <= 0;
            if (operation == start) begin //Press some key to start
                state <= generator;
            end
        end

        generator : begin  //tetrimino = hash(frame_value)

            centerofmass[1][0] <= 0;
            centerofmass[0][0] <= 5; //The block that acts as CM, doesn't change on rotation
            tetrimino = (framenumber) % (prevtetrimino+1);
            
            case(tetrimino) 
            straight : begin //straight
            centerofmass[0][1] <= 3;
            centerofmass[1][1] <= 0;
            centerofmass[0][2] <= 4;
            centerofmass[1][2] <= 0;
            centerofmass[0][3] <= 6;
            centerofmass[1][3] <= 0;
            end
            L : begin   //L-Shaped 
            centerofmass[0][1] <= 4;
            centerofmass[1][1] <= 1;
            centerofmass[0][2] <= 4;
            centerofmass[1][2] <= 0;
            centerofmass[0][3] <= 6;
            centerofmass[1][3] <= 0;
            end

            LEn : begin // L-Shaped Enantiomer
            centerofmass[0][1] <= 4;
            centerofmass[1][1] <= 0;
            centerofmass[0][2] <= 6;
            centerofmass[1][2] <= 0;
            centerofmass[0][3] <= 6;
            centerofmass[1][3] <= 1;
            end

            Skew : begin //Skew
            centerofmass[0][1] <= 4;
            centerofmass[1][1] <= 0;
            centerofmass[0][2] <= 5;
            centerofmass[1][2] <= 1;
            centerofmass[0][3] <= 6;
            centerofmass[1][3] <= 1;
            end

            SkewEn: begin //Skew Enantiomer
            centerofmass[0][1] <= 6;
            centerofmass[1][1] <= 0;
            centerofmass[0][2] <= 5;
            centerofmass[1][2] <= 1;
            centerofmass[0][3] <= 4;
            centerofmass[1][3] <= 1;
            end
            Block : begin //Block
            centerofmass[0][1] <= 6;
            centerofmass[1][1] <= 0;
            centerofmass[0][2] <= 5;
            centerofmass[1][2] <= 1;
            centerofmass[0][3] <= 6;
            centerofmass[1][3] <= 1;
            end

            T : begin //T-Block
            centerofmass[0][1] <= 4;
            centerofmass[1][1] <= 0;
            centerofmass[0][2] <= 6;
            centerofmass[1][2] <= 0;
            centerofmass[0][3] <= 5;
            centerofmass[1][3] <= 1;
            end

            default: begin // bullshit test block
            centerofmass[0][1] <= 0;
            centerofmass[1][1] <= 0;
            centerofmass[0][2] <= 0;
            centerofmass[1][2] <= 0;
            centerofmass[0][3] <= 0;
            centerofmass[1][3] <= 0;
            end
            endcase
            state <= update; //Update the frame with the new tetrimino
        end
        standby : begin
            if( clk == 8 || operation == 5 ) begin
            state <= testfalldown;
            end
            if(operation == 1) begin
            state <= testleft;
            end
            if(operation == 2) begin
            state <= testright;
            end
            if(operation == 3) begin
            state <= testrotate; 
            end
        end

        testfalldown : begin
            for(i = 0;i<4;i=i+1) begin
                tempcoords[0][j] <= centerofmass[0][j];
                tempcoords[1][j] <= centerofmass[1][j]+1;
            end
            if(~invalid(centerofmass,tempcoords,currentstate)) begin
                for(i = 0;i<2;i=i+1) begin
                    for(j=0;j<4;j=j+1) begin                       //Make currentcoordinates correct
                        centerofmass[i][j] <= tempcoords[i][j];
                    end
                end
                state<=update;
            end
        else begin
               state <= testgameover;
           end
   end
   testgameover : begin
       gameover = 0; 
    
        for(i=0; i<10; i=i+1) begin 
            gameover = gameover + currentstate[i][0]; //If any of the top y coordinates are 1, you get gameover
           end
       
        if(gameover != 0) begin
           state <= 15; //Goback to default state
        end
        else begin
           state <= rowdeletion;
        end
    end

   rowdeletion: begin
       rowvalue = 1;
       for(i =0;i<20;i=i+1) begin
           for(j = 0;j<10;j=j+1) begin
               rowvalue = rowvalue*currentstate[i][j];
           end
           if(rowvalue == 1)begin
               score <=score +1;
               for(j = 0;j<10;j=j+1) begin
                   for(k = i;k>0;k=k-1) begin
                       currentstate[j][k] <= currentstate[j][k-1];
                    end
                end
            end
        end

        state <= generator;
    end

    testleft : begin
        for(i = 0;i<4;i=i+1) begin
           tempcoords[0][i] <= centerofmass[0][i] -1;
           tempcoords[1][i] <= centerofmass[1][i];
        end
        if(!invalid(centerofmass,tempcoords,currentstate)) begin
            for(i = 0;i<2;i=i+1) begin
                for(j=0;j<4;j=j+1) begin
                    centerofmass[i][j] <= tempcoords[i][j];
                end
            end
            state <= update;
            end
        else begin
               state <= standby;
           end

    end
    testright : begin
        for(i = 0;i<4;i=i+1) begin
           tempcoords[0][j] <= centerofmass[0][j] +1;
           tempcoords[1][j] <= centerofmass[1][j];
        end
        if(!invalid(centerofmass,tempcoords,currentstate)) begin
            for(i = 0;i<2;i=i+1) begin
                for(j=0;j<4;j=j+1) begin
                    centerofmass[i][j] <= tempcoords[i][j];
                end
            end
            state<=update;
            end
        else begin
               state <= standby;
           end

   end
   testrotate : begin
       for(i = 1;i<4;i=i+1) begin
           tempcoords[0][j] <= centerofmass[1][j] - centerofmass[1][0]+centerofmass[0][0]; //90 deg rot about coordinates of CM
           tempcoords[1][j] <= centerofmass[0][0] + centerofmass[1][0] - centerofmass[0][j];
       end
        if(!invalid(centerofmass,tempcoords,currentstate)) begin
            for(i = 0;i<2;i=i+1) begin
                for(j=0;j<4;j=j+1) begin
                    centerofmass[i][j] <= tempcoords[i][j];
                end
            end
            state<=update;
            end
        else begin
               state <= standby;
           end
   end

   update : begin
        for (j = 0;j<4;j=j+1) begin
            currentstate[prevcenterofmass[0][j]][prevcenterofmass[1][j]] <= 0; //Transform the currentstate to meet valid move
        end
         for (j = 0;j<4;j=j+1) begin
             currentstate[centerofmass[0][j]][centerofmass[1][j]] <= 1; 
         end
         for(i=0;i<2;i=i+1) begin
             for(j=0;j<4;j=j+1) begin
             prevcenterofmass[i][j] <= centerofmass[i][j];
             end
         end

        state <= standby;
        
        end 


endcase
   end

function invalid (input reg [4:0] currentcoords[0:1][0:3], input reg[4:0] newcmass[0:1][0:3],
    input reg boardstate[0:9][0:19] );

    assign invalid = currentstatecheck(boardstate, currentcoords, newcmass) || boundarycheck(newcmass);
    
endfunction

function currentstatecheck;
    input reg bstate [0:9][0:19];
    input reg [4:0] currentcoords [0:1][0:3];
    input reg [4:0] newcoords [0:1][0:3];
    //Erase the currently stored tetrimino And check whether the positions of the new tetrimino are occupied. 
    //currentstatecheck = 0; 
    integer i;
    for(i = 0;i<4;i=i+1) begin
        bstate[currentcoords[0][i]][currentcoords[1][i]] = bstate[currentcoords[0][i]][currentcoords[1][i]]-1;
    end

    for(i = 0;i<4;i=i+1) begin
        if(bstate[newcoords[0][i]][newcoords[1][i]]==1) begin
            currentstatecheck = 1;
        end
    end 
endfunction

function boundarycheck (input [4:0] coordinatearr [0:1][0:3]);
reg data = 0;
integer i;
for(i=0;i<4;i=i+1) begin
    if(coordinatearr[0][i] > 10) begin //if it goes to the left, reg will cycle to 32. Right is obvious
        data = 1; 
    end
    if(coordinatearr[1][i]>19)begin //If it goes below 0 barrier boundary, reg will cycle to 32. 
        data = 1;
    end   
end
boundarycheck = data;
endfunction

endmodule

        
        











                                  

