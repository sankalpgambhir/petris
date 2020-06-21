// internal vga sync signal and print counter generation

module vga_sync_gen(
    input clock,
    output reg hsync,               // line end
    output reg vsync,               // screen end
    output reg in_display,          // whether in printing area
    output reg [9:0] count_x,
    output reg [9:0] count_y        // extended to 10 bits for uniformity
);
                                    // front_porch + sync + back_porch + display
    wire high_x = (count_x == 17); // 1 + 5 + 1 + 10
    wire high_y = (count_y == 24); // 1 + 2 + 1 + 20

    // increment or loop x and y
    always @(posedge clock) begin
        if (high_x) begin
            count_x = 0;
            if (high_y)
                count_y = 0;
            else
                count_y = count_y + 1;
        end
        else
            count_x = count_x + 1; 
    end

    // set sync and display signals
    always @(posedge clock) begin
        // ~*sync if count_# in sync region in # direction
        // low only in sync region
        hsync <= ~(count_x > (10 + 1) && count_x < (10 + 1 + 5));
        vsync <= ~(count_y > (20 + 1) && count_y < (20 + 1 + 2));

        in_display <= (count_x < 10) && (count_y < 20);
    end

endmodule