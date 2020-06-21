// Low level VGA controller implementation
// with frame buffer

module vga_control(
    input clock,
    input reg [2:0] frame [0:9] [0:19], // fb [x][y][R | G | B]
    output reg [2:0] vga_pixel,
    output hsync_out,
    output vsync_out,
    output in_display,
    output reg [9:0] count_x,
    output reg [9:0] count_y
    );

    wire vga_clock;

    vga_sync_clock sync_clock(
        .clock(clock),
        .vga_clock(vga_clock)
    );

    // generate count and sync signals
    vga_sync_gen sync(
        vga_clock,
        hsync_out,
        vsync_out,
        in_display,
        count_x,
        count_y
    );

    always @(negedge vga_clock) begin
        if (in_display) begin
            vga_pixel <= frame[count_x][count_y];
            //vga_pixel <= 3'b111;      // testing
        end
        else
            // if not in display area, show black
            vga_pixel <= 3'b111;
    end

    // output call to vga_sim
    // TO BE ADDED

endmodule