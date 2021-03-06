// base clock for operations, assumed provided by board
// using C++ clock
//`timescale 1ns / 1ns

module amain_wrapper(
    input clock,
    input reg [4:0] actions,
    output vsync,
    output hsync,
    output in_display,
    output vga_r,
    output vga_g,
    output vga_b,
    output reg [9:0] count_x,
    output reg [9:0] count_y,
    output reg [7:0] score,
    output reg gameover
    );

    // clock incremented from C++ wrapper


    reg [2:0] prev_state [0:9] [0:19];
    reg [2:0] frame_buffer [0:9] [0:19];
    reg [2:0] frame_out [0:9] [0:19];
    reg [2:0] next_piece; // randomly generated ig

    reg [2:0] pixel;
    reg [10:0] fcounter;

    assign vga_r = pixel[2];
    assign vga_g = pixel[1];
    assign vga_b = pixel[0];

    initial begin
        next_piece = 3'b111;
        fcounter = 0;
        vga_r = 1;
    end

    vga_control vga_inst(
        .clock(clock),
        .frame(frame_out),
        .vga_pixel(pixel),
        .hsync_out(hsync),
        .vsync_out(vsync),
        .in_display(in_display),
        .count_x(count_x),
        .count_y(count_y)
    );


    
    tetriminogeneration tet_inst(
        .currentstate(frame_buffer),
        .operation(actions),
        .score(score),
        .vsync(vsync),
        .framenumber(fcounter),
        .gameover(gameover),
        .clock(clock)
    ); 
    
    framer framer_inst(vsync, frame_out, frame_buffer);
    
    always @(posedge vsync)begin
        //$display("Frame;");
        //$display(fcounter);
        fcounter = fcounter+1;
    end
    


endmodule