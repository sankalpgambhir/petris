// base clock for operations, assumed provided by board
// using C++ clock
//`timescale 1ns / 1ns

module main_wrapper(
    input clock,
    input reg [1:0] actions,
    output vsync,
    output hsync,
    output in_display,
    output reg [9:0] count_x,
    output reg [9:0] count_y,
    output vga_clock
    );

    // clock incremented from C++ wrapper

    
    reg r, g, b;

    faker fake_inst(r,g,b);

    vga_sync_clock sync_clock(
        .clock(clock),
        .vga_clock(vga_clock)
    );

    initial begin
        // filler
    end

    always @(posedge clock) begin
        if(actions[0])
            $display("right");
        if(actions[1])
            $display("left");        
    end

    // temporarily instantiate every module to have only one top module
    reg [2:0] frame_out [0:799] [0:524];
    reg [15:0] GLYPH_ROM [0:255][0:7];
    framer framer_inst(vsync, frame_out);
    vga_control vga_cont(
        vga_clock,
        frame_out,
        r,
        g,
        b,
        hsync,
        vsync,
        in_display,
        count_x,
        count_y
    );
    rom rom_inst(GLYPH_ROM);   

    always @(posedge vsync)begin
        $display("Frame;");
    end 


endmodule


module faker(output r, g, b);
    // fake shit
endmodule