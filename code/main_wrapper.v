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


endmodule
