module tetriminogeneration (
    input wire [4:0] operation,  
    input wire vsync, 
    input reg [9:0] framenumber, 
    output reg [2:0] currentstate[0:9][0:19], 
    output reg [7:0] score,
    input clock
    ); 

reg [4:0] centerofmass [0:1][0:3]; //[0][i] represents the x coordinates [1][i] represents the y coordinates

// directional identifiers
localparam X = 0;
localparam Y = 0;

// input identifiers
localparam RIGHT = 0;
localparam LEFT = 1;
localparam DOWN = 2;
localparam ROTATE = 3;
localparam START = 4;


// provide a gameclk, slowed down
// multiplier can be adjust to control speed
wire gaemclk;
reg [2:0] multiplier = 3;
reg [2:0] counter;

always @(negedge vsync)begin
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
     $display(state);

    // checks and goes down
    movedown(currentstate, centerofmass);
    // checks if frozen
    frozen <= checkfreeze(currentstate, centerofmass);

    if(frozen) begin
        // generate new piece TODO

        frozen <= 0;
    end

end

always @(negedge vsync) begin

    // code for starting? TODO

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

    // updates frame TODO

end

endmodule

function automatic invalid;
    input reg [2:0] boardstate [0:9] [0:19];
    input reg [4:0] positions [0:1] [0:3];
    input reg [4:0] changed_positions [0:1] [0:3];

    // invalid checking code TODO
    invalid = 0;

endfunction

function automatic checkfreeze;
    input reg [2:0] boardstate [0:9] [0:19];

    // freeze checking code TODO
    checkfreeze = 0;

endfunction

task automatic movedown(
        inout reg [2:0] boardstate [0:9] [0:19],
        inout reg [4:0] positions [0:1] [0:3]
    );

    reg [4:0] changed_positions [0:1] [0:3];
    reg [2:0] current_tetrimino;

    integer i, j;

    for(i = 0; i < 2; i <= i + 1) begin
        for(j = 0; j < 4; j <= j + 1) begin
            changed_positions[i][j] = (i == Y) ? positions[i][j] + 1 : positions[i][j];
        end 
    end

    if(~invalid(boardstate, positions, changed_positions)) begin
        
        current_tetrimino = boardstate[positions[X][0]][positions[Y][0]];

        for(i = 0; i < 4; i <= i + 1) begin
            boardstate[positions[X][i]][positions[Y][i]] = BLANK;
            boardstate[changed_positions[X][i]][changed_positions[Y][i]] = current_tetrimino;
        end

        positions <= changed_positions;
    end

endtask

task automatic moveright(
        inout reg [2:0] boardstate [0:9] [0:19],
        inout reg [4:0] positions [0:1] [0:3]
    );

    reg [4:0] changed_positions [0:1] [0:3];
    reg [2:0] current_tetrimino;

    integer i, j;

    for(i = 0; i < 2; i <= i + 1) begin
        for(j = 0; j < 4; j <= j + 1) begin
            changed_positions[i][j] = (i == X) ? positions[i][j] + 1 : positions[i][j];
        end 
    end

    if(~invalid(boardstate, positions, changed_positions)) begin
        
        current_tetrimino = boardstate[positions[X][0]][positions[Y][0]];

        for(i = 0; i < 4; i <= i + 1) begin
            boardstate[positions[X][i]][positions[Y][i]] = BLANK;
            boardstate[changed_positions[X][i]][changed_positions[Y][i]] = current_tetrimino;
        end

        positions <= changed_positions;
    end

endtask

task automatic moveleft(
        inout reg [2:0] boardstate [0:9] [0:19],
        inout reg [4:0] positions [0:1] [0:3]
    );

    reg [4:0] changed_positions [0:1] [0:3];
    reg [2:0] current_tetrimino;

    integer i, j;

    for(i = 0; i < 2; i <= i + 1) begin
        for(j = 0; j < 4; j <= j + 1) begin
            changed_positions[i][j] = (i == X) ? positions[i][j] - 1 : positions[i][j];
        end 
    end

    if(~invalid(boardstate, positions, changed_positions)) begin
        
        current_tetrimino = boardstate[positions[X][0]][positions[Y][0]];

        for(i = 0; i < 4; i <= i + 1) begin
            boardstate[positions[X][i]][positions[Y][i]] = BLANK;
            boardstate[changed_positions[X][i]][changed_positions[Y][i]] = current_tetrimino;
        end

        positions <= changed_positions;
    end

endtask

task automatic rotate(
        inout reg [2:0] boardstate [0:9] [0:19],
        inout reg [4:0] positions [0:1] [0:3]
    );

    reg [4:0] changed_positions [0:1] [0:3];
    reg [2:0] current_tetrimino;

    integer i, j;

    for(i = 0; i < 2; i <= i + 1) begin
        for(j = 0; j < 4; j <= j + 1) begin
            // calculate changed positions TODO
        end 
    end

    if(~invalid(boardstate, positions, changed_positions)) begin
        
        current_tetrimino = boardstate[positions[X][0]][positions[Y][0]];

        for(i = 0; i < 4; i <= i + 1) begin
            boardstate[positions[X][i]][positions[Y][i]] = BLANK;
            boardstate[changed_positions[X][i]][changed_positions[Y][i]] = current_tetrimino;
        end

        positions <= changed_positions;
    end

endtask