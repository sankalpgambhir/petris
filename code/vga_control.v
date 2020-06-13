// Low level VGA controller implementation
// with frame buffer

module vga_control(
    input clock,
    input reg [2:0] frame_buffer [0:799] [0:524], // fb [x][y][R | G | B]
    output reg [2:0] vga_pixel,
    output hsync_out,
    output vsync_out
    );

    // I haven't actually used these for now so they're on trial for removal
    localparam R = 0;
    localparam G = 1;
    localparam B = 2;

    wire in_display;
    wire [9:0] count_x;
    wire [9:0] count_y;

    // generate count and sync signals
    vga_sync_gen sync(
        clock,
        hsync_out,
        vsync_out,
        in_display,
        count_x,
        count_y
    );

    always @(posedge clock) begin
        if (in_display)
            vga_pixel <= frame_buffer[count_x][count_y];
        else
            // if not in display area, show black
            vga_pixel <= 3'b000;
    end

    // output call to vga_sim
    // TO BE ADDED

endmodule