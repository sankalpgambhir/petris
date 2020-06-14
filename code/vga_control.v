// Low level VGA controller implementation
// with frame buffer

module vga_control(
    input clock,
    input reg [2:0] frame_buffer [0:799] [0:524], // fb [x][y][R | G | B]
    output wire vga_r,
    output wire vga_g,
    output wire vga_b,
    output hsync_out,
    output vsync_out,
    output in_display,
    output reg [9:0] count_x,
    output reg [9:0] count_y
    );

    localparam R = 0;
    localparam G = 1;
    localparam B = 2;

    //wire in_display;
    //wire [9:0] count_x;
    //wire [9:0] count_y;

    reg [2:0] vga_pixel;

    assign vga_r = vga_pixel[R];
    assign vga_g = vga_pixel[G];
    assign vga_b = vga_pixel[B];

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