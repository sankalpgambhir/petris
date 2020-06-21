// global parameters

// tetrimino types
parameter straight = 3'b111;
parameter L = 3'b100;
parameter LEn = 3'b001;
parameter Skew = 3'b010;
parameter SkewEn = 3'b110;
parameter Block = 3'b101;
parameter T = 3'b011;
parameter BLANK = 3'b000; // explicit blanking identifier

// directional identifiers
localparam dir_X = 0;
localparam dir_Y = 1;

// input identifiers
localparam RIGHT = 0;
localparam LEFT = 1;
localparam DOWN = 2;
localparam ROTATE = 3;
localparam START = 4;

module tetriminogeneration (
    input wire [4:0] operation,  
    input wire vsync, 
    input reg [9:0] framenumber, 
    output reg [2:0] currentstate[0:9][0:19], 
    output reg [7:0] score,
    input clock
    ); 

reg [4:0] centerofmass [0:1][0:3]; //[0][i] represents the x coordinates [1][i] represents the y coordinates


// provide a gameclk, slowed down
// multiplier can be adjust to control speed
reg gameclk;
reg [2:0] multiplier = 2;
reg [2:0] counter;

// game state variables
reg [2:0] tetrimino = straight;
reg frozen = 0;
reg gameover = 0;

reg [2:0] num_deleted;
integer i;

initial begin
    generate_new(centerofmass, tetrimino);

    for(i = 0; i < 4; i = i + 1) begin
        currentstate[centerofmass[dir_X][i]][centerofmass[dir_Y][i]] = tetrimino;
    end
end

always @(posedge vsync)begin
    counter <= counter + 1;
    if (counter == multiplier) begin
        counter <= 0;
        gameclk <= ~gameclk;
    end
end


always @(posedge gameclk) begin 

     $display("gameclk: ");
     $display(gameclk);
     $display(operation);
     $display(tetrimino);
     $display(centerofmass[dir_Y][0]);

    // checks and goes down
    movedown(currentstate, centerofmass);
    // checks if frozen
    frozen = checkfreeze(currentstate, centerofmass);

    if(frozen) begin
        // check for row deletion
        num_deleted = 0;
        row_deletion(currentstate, centerofmass, num_deleted);
        
        // update score
        score = score + score_increment(num_deleted); 

        // check for loss
        gameover = has_lost(currentstate);
        
        // generate new piece
        tetrimino = ($random % 7) + 1; // randomizer TODO
        generate_new(centerofmass, tetrimino);

        for(i = 0; i < 4; i = i + 1) begin
            currentstate[centerofmass[dir_X][i]][centerofmass[dir_Y][i]] = tetrimino;
        end

        frozen = 0;
    end

end

always @(negedge vsync) begin

    // code for starting? TODO
    // stop when lost TODO

    // check if input provided
    if(operation) begin
        // check validity, move accordingly

        // if down move down
        if(operation[DOWN]) begin
            // check
            // move down
            movedown(currentstate, centerofmass);
        end

        // if left or right, move there
        if(operation[LEFT] || operation[RIGHT]) begin
            if(~operation[LEFT]) begin
                // check and move right
                moveright(currentstate, centerofmass);
            end
            else if(~operation[RIGHT]) begin
                // check and move left
                moveleft(currentstate, centerofmass);
            end
        end

        // if rotate, rotate the piece
        if(operation[ROTATE]) begin
            // check and rotate
            rotate(currentstate, centerofmass);
        end

    end

    // update frame 
    // done automatically if moved

end

endmodule

function automatic invalid;
    input reg [2:0] boardstate [0:9] [0:19];
    input reg [4:0] positions [0:1] [0:3];
    input reg [4:0] changed_positions [0:1] [0:3];

    invalid = currentstatecheck(boardstate, positions, changed_positions) || boundarycheck(changed_positions);

endfunction

function automatic currentstatecheck;
    input reg [2:0] boardstate [0:9][0:19];
    input reg [4:0] positions [0:1][0:3];
    input reg [4:0] changed_positions [0:1][0:3];

    reg data = 0;

    integer i;
    for(i = 0; i < 4; i = i + 1) begin
        boardstate[positions[dir_X][i]][positions[dir_Y][i]] = 0;
    end

    for(i = 0; i < 4; i = i + 1) begin
        if(boardstate[changed_positions[dir_X][i]][changed_positions[dir_Y][i]]!=0) begin
            data = 1;
        end
    end

    currentstatecheck = data;

endfunction

function automatic boundarycheck; 
    input [4:0] changed_positions [0:1][0:3];

    reg data = 0;

    integer i;
    for(i = 0; i < 4; i = i + 1) begin
        if(changed_positions[dir_X][i] > 9) begin //if it goes to the left, reg will cycle to 32. Right is obvious
            data = 1; 
        end
        if(changed_positions[dir_Y][i] > 19) begin //If it goes below 0 barrier boundary, reg will cycle to 32. 
            data = 1;
        end   
    end

    boundarycheck = data;

endfunction

function automatic checkfreeze;
    input reg [2:0] boardstate [0:9] [0:19];
    input reg [4:0] positions [0:1][0:3];

    reg data = 0;

    integer i;
    for(i = 0; i < 4; i = i + 1) begin
        boardstate[positions[dir_X][i]][positions[dir_Y][i]] = 0;
    end

    for(i = 0; i < 4; i = i + 1) begin
        if(positions[dir_Y][i] == 19) begin
            data = 1;
        end
        else if(boardstate[positions[dir_X][i]][positions[dir_Y][i] + 1]) begin
            data = 1;
        end
    end

    checkfreeze = data;

endfunction

function automatic has_lost;
    input reg [2:0] boardstate [0:9] [0:19];

    reg live = 1;
    integer i;

    for(i = 0; i < 10; i = i + 1) begin
        live = live && ~(boardstate[i][0]);
    end

    has_lost = ~live;
    
endfunction

function score_increment;
    input reg [2:0] num_deleted;
    
    case(num_deleted)
        4 : score_increment = 10;
        3 : score_increment = 7;
        2 : score_increment = 3;
        1 : score_increment = 1;
        default : score_increment = 0;
    endcase

endfunction

task automatic movedown(
        inout reg [2:0] boardstate [0:9] [0:19],
        inout reg [4:0] positions [0:1] [0:3]
    );

    reg [4:0] changed_positions [0:1] [0:3];
    reg [2:0] current_tetrimino;

    integer i, j;

    for(i = 0; i < 2; i = i + 1) begin
        for(j = 0; j < 4; j = j + 1) begin
            changed_positions[i][j] = ((i == dir_Y) ? (positions[i][j] + 1) : positions[i][j]);
        end 
    end

    if(~invalid(boardstate, positions, changed_positions)) begin
        
        current_tetrimino = boardstate[positions[dir_X][0]][positions[dir_Y][0]];

        // clear
        for(i = 0; i < 4; i = i + 1) begin
            boardstate[positions[dir_X][i]][positions[dir_Y][i]] = BLANK;
        end
        // rewrite
        for(i = 0; i < 4; i = i + 1) begin
            boardstate[changed_positions[dir_X][i]][changed_positions[dir_Y][i]] = current_tetrimino;
        end

        positions = changed_positions;
    end

endtask

task automatic moveright(
        inout reg [2:0] boardstate [0:9] [0:19],
        inout reg [4:0] positions [0:1] [0:3]
    );

    reg [4:0] changed_positions [0:1] [0:3];
    reg [2:0] current_tetrimino;

    integer i, j;

    for(i = 0; i < 2; i = i + 1) begin
        for(j = 0; j < 4; j = j + 1) begin
            changed_positions[i][j] = ((i == dir_X) ? (positions[i][j] + 1) : positions[i][j]);
        end 
    end

    if(~invalid(boardstate, positions, changed_positions)) begin
        
        current_tetrimino = boardstate[positions[dir_X][0]][positions[dir_Y][0]];

        // clear
        for(i = 0; i < 4; i = i + 1) begin
            boardstate[positions[dir_X][i]][positions[dir_Y][i]] = BLANK;
        end
        // rewrite
        for(i = 0; i < 4; i = i + 1) begin
            boardstate[changed_positions[dir_X][i]][changed_positions[dir_Y][i]] = current_tetrimino;
        end

        positions = changed_positions;
    end

endtask

task automatic moveleft(
        inout reg [2:0] boardstate [0:9] [0:19],
        inout reg [4:0] positions [0:1] [0:3]
    );

    reg [4:0] changed_positions [0:1] [0:3];
    reg [2:0] current_tetrimino;

    integer i, j;

    for(i = 0; i < 2; i = i + 1) begin
        for(j = 0; j < 4; j = j + 1) begin
            changed_positions[i][j] = ((i == dir_X) ? (positions[i][j] - 1) : positions[i][j]);
        end 
    end

    if(~invalid(boardstate, positions, changed_positions)) begin
        
        current_tetrimino = boardstate[positions[dir_X][0]][positions[dir_Y][0]];

        // clear
        for(i = 0; i < 4; i = i + 1) begin
            boardstate[positions[dir_X][i]][positions[dir_Y][i]] = BLANK;
        end
        // rewrite
        for(i = 0; i < 4; i = i + 1) begin
            boardstate[changed_positions[dir_X][i]][changed_positions[dir_Y][i]] = current_tetrimino;
        end

        positions = changed_positions;
    end

endtask

task automatic rotate(
        inout reg [2:0] boardstate [0:9] [0:19],
        inout reg [4:0] positions [0:1] [0:3]
    );

    reg [4:0] changed_positions [0:1] [0:3];
    reg [2:0] current_tetrimino;

    integer i, j;

    for(i = 0; i < 2; i = i + 1) begin
        for(j = 0; j < 4; j = j + 1) begin
            // calculate rotated positions TODO
        end 
    end

    if(~invalid(boardstate, positions, changed_positions)) begin
        
        current_tetrimino = boardstate[positions[dir_X][0]][positions[dir_Y][0]];

        // clear
        for(i = 0; i < 4; i = i + 1) begin
            boardstate[positions[dir_X][i]][positions[dir_Y][i]] = BLANK;
        end
        // rewrite
        for(i = 0; i < 4; i = i + 1) begin
            boardstate[changed_positions[dir_X][i]][changed_positions[dir_Y][i]] = current_tetrimino;
        end

        positions = changed_positions;
    end

endtask

task automatic generate_new(
    inout reg [4:0] positions [0:1] [0:3],
    input reg [2:0] tetrimino 
    );

    // write new positions for generated tetrimino


    // write the center
    positions[dir_X][0] = 5;
    positions[dir_Y][0] = 0;

    // write the others

    case(tetrimino) 
        straight : begin //straight
        positions[0][1] = 3;
        positions[1][1] = 0;
        positions[0][2] = 4;
        positions[1][2] = 0;
        positions[0][3] = 6;
        positions[1][3] = 0;
        end

        L : begin   //L-Shaped 
        positions[0][1] = 4;
        positions[1][1] = 1;
        positions[0][2] = 4;
        positions[1][2] = 0;
        positions[0][3] = 6;
        positions[1][3] = 0;
        end

        LEn : begin // L-Shaped Enantiomer
        positions[0][1] = 4;
        positions[1][1] = 0;
        positions[0][2] = 6;
        positions[1][2] = 0;
        positions[0][3] = 6;
        positions[1][3] = 1;
        end

        Skew : begin //Skew
        positions[0][1] = 4;
        positions[1][1] = 0;
        positions[0][2] = 5;
        positions[1][2] = 1;
        positions[0][3] = 6;
        positions[1][3] = 1;
        end

        SkewEn: begin //Skew Enantiomer
        positions[0][1] = 6;
        positions[1][1] = 0;
        positions[0][2] = 5;
        positions[1][2] = 1;
        positions[0][3] = 4;
        positions[1][3] = 1;
        end
        Block : begin //Block
        positions[0][1] = 6;
        positions[1][1] = 0;
        positions[0][2] = 5;
        positions[1][2] = 1;
        positions[0][3] = 6;
        positions[1][3] = 1;
        end

        T : begin //T-Block
        positions[0][1] = 4;
        positions[1][1] = 0;
        positions[0][2] = 6;
        positions[1][2] = 0;
        positions[0][3] = 5;
        positions[1][3] = 1;
        end

        default: begin // bullshit test block
        positions[0][1] = 10;
        positions[1][1] = 10;
        positions[0][2] = 10;
        positions[1][2] = 11;
        positions[0][3] = 10;
        positions[1][3] = 12;
        end
    endcase

endtask

task automatic row_deletion(
        inout reg [2:0] boardstate [0:9] [0:19],
        input reg [4:0] positions [0:1] [0:3],
        output reg [2:0] num_deleted
    );

    reg [19:0] deleted;
    
    reg [4:0] curr_row = 0;
    reg to_delete_curr;

    integer i, j;

    num_deleted = 0;
    

    // check all rows of frozen piece
    // mark deleted ones
    for(i = 0; i < 4; i = i + 1)begin
        curr_row = positions[dir_Y][i];
        to_delete_curr = 1;

        for(j = 0; j < 10; j = j + 1) begin
            to_delete_curr = to_delete_curr && (boardstate[j][curr_row] ? 1 : 0);
        end

        deleted[curr_row] = to_delete_curr;
        num_deleted = num_deleted + (to_delete_curr ? 1 : 0);

    end

    // flow
    for(i = 19; i > -1; i = i - 1) begin
        if(deleted[i]) begin
            if(i == 0) begin
                for(j = 0; j < 10; j = j + 1) begin
                    boardstate[j][i] = BLANK;
                end
            end
            else begin
                for(j = 0; j < 10; j = j + 1) begin
                    boardstate[j][i] = boardstate[j][i - 1];
                end
                deleted[i] = deleted[i - 1];
                deleted[i - 1] = 1;
                i = i + 1;
            end
        end
    end


endtask