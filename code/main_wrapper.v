// base clock for operations, assumed provided by board
// using C++ clock
//`timescale 1ns / 1ns

module main_wrapper();
    reg clock;
    reg vga_clock;

    // clock incremented from C++ wrapper

    vga_sync_clock sync_clock(
        .clock(clock),
        .vga_clock(vga_clock)
    );

    initial begin
        // filler
    end

    // temporarily instantiate every module to have only one top module
    reg [2:0] frame_out [0:799] [0:524];
    reg [2:0] vga_pixel;
    reg hsync, vsync;
    reg [15:0] GLYPH_ROM [0:255][0:7];
    framer framer_inst(vsync, frame_out);
    vga_control vga_cont(
        vga_clock,
        frame_out,
        vga_pixel,
        hsync,
        vsync
    );
    rom rom_inst(GLYPH_ROM);    


endmodule
