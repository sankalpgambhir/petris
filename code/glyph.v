// interface for drawing ASCII glyphs on screen

function glyph;
    input [9:0] coord_x,
    input [9:0] coord_y,
    input [7:0] ascii,
    input [2:0] color;

    begin
        localparam pitch = 8;
        // draw glyphs from rom
        for(i = 0; i < 8 * 16; i = i + 1) begin
            reg [2:0] counter_x = 3'b000;
            reg [3:0] counter_y = 3'b0000;
            if (rom.GLYPH_ROM[ascii][counter_x][counter_y])
                framer.frame_buffer[coord_x + counter_x][coord_y + counter_y] <= color;
            
            if(counter_x == 3'b111) begin
                counter_x <= 3'b000;
                counter_y <= counter_y + 1;
            end
            else
                counter_x <= counter_x + 1;
        end
    end

endfunction