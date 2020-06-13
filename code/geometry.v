// general purpose functions to draw glyphs and figures

// #include framer.v

// draw a rectangle to the buffer
function draw_filled_rect;
    input [9:0] coord_x,
    input [9:0] coord_y,
    input [9:0] dim_x,
    input [9:0] dim_y,
    input [2:0] color;

    begin
        overflow <= (coord_x + dim_x > 640) || (coord_y + dim_y > 480);   

        if (overflow) begin
            $display("Error: draw_filled_rect::overflow -- skipping.");
            draw_filled_rect = 1;
        end
        else begin
            for (i = coord_x; i < coord_x + dim_x; i = i + 1) begin
                for (j = coord_y; j < coord_y + dim_y; i = j + 1) begin
                    framer.frame_buffer[i][j] <= color;
                end
            end

            draw_filled_rect = 0;
        end

    end

endfunction

// draw an empty rectangle to the buffer
// note: stroked inside
function draw_rect;
    input [9:0] coord_x,
    input [9:0] coord_y,
    input [9:0] dim_x,
    input [9:0] dim_y,
    input [2:0] color,
    input [9:0] width; // stroke size in pixels, 10 bits for uniformity

    begin
        overflow <= (coord_x + dim_x > 640) || (coord_y + dim_y > 480);   

        if (overflow) begin
            $display("Error: draw_rect::overflow -- skipping.");
            draw_rect = 1;
        end
        else begin
            draw_filled_rect(coord_x, coord_y, dim_x, width, color);
            draw_filled_rect(coord_x, coord_y, width, dim_y, color);
            draw_filled_rect(coord_x + dim_x - width, coord_y, width, dim_y, color);
            draw_filled_rect(coord_x, coord_y + dim_y - width, dim_x, width, color);
            draw_rect = 0;
        end

    end

endfunction