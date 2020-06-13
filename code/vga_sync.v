// internal vga sync signal and print counter generation

module vga_sync(
    input clock,
    output reg hsync,               // line end
    output reg vsync,               // screen end
    output reg in_display,          // whether in printing area
    output reg [9:0] count_x,
    output reg [9:0] count_y        // extended to 10 bits for uniformity
);
                                    // front_porch + sync + back_porch + display
    wire high_x = (count_x == 800); // 16 + 48 + 96 + 640
    wire high_y = (count_y == 525); // 10 + 2 + 33 + 480

    // increment or loop x and y
    always @(posedge clock) begin
        if (high_x) begin
            count_x <= 0;
            if (high_y)
                count_y <= 0;
            else
                count_y <= count_y + 1;
        end
        else
            count_x <= count_x + 1; 
    end

    // set sync and display signals
    always @(posedge clock) begin
        // ~*sync if count_# in sync region in # direction
        // low only in sync region
        hsync <= ~(count_x > (640 + 16) && count_x < (640 + 16 + 48));
        vsync <= ~(count_y > (480 + 10) && count_y < (480 + 10 + 2));

        in_display <= (count_x < 640) && (count_y < 480);
    end

endmodule