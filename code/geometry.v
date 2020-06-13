// general purpose functions to draw glyphs and figures

// #include framer.v

// draw a rectangle to the buffer
function automatic draw_filled_rect;
    input reg [2:0] frame_buffer [0:799] [0:524];
    input [9:0] coord_x;
    input [9:0] coord_y;
    input [9:0] dim_x;
    input [9:0] dim_y;
    input [2:0] color;

    begin
        reg overflow = (coord_x + dim_x > 640) || (coord_y + dim_y > 480);   

        if (overflow) begin
            $display("Error: draw_filled_rect::overflow -- skipping.");
            draw_filled_rect = 1;
        end
        else begin
            integer i, j;
            for (i = coord_x; i < coord_x + dim_x; i = i + 1) begin
                for (j = coord_y; j < coord_y + dim_y; i = j + 1) begin
                    frame_buffer[i][j] <= color;
                end
            end

            draw_filled_rect = 0;
        end

    end

endfunction

// draw an empty rectangle to the buffer
// note: stroked inside
function automatic draw_rect;
    input reg [2:0] frame_buffer [0:799] [0:524];
    input [9:0] coord_x;
    input [9:0] coord_y;
    input [9:0] dim_x;
    input [9:0] dim_y;
    input [2:0] color;
    input [9:0] width; // stroke size in pixels, 10 bits for uniformity

    begin
        reg overflow = (coord_x + dim_x > 640) || (coord_y + dim_y > 480);   

        if (overflow) begin
            $display("Error: draw_rect::overflow -- skipping.");
            draw_rect = 1;
        end
        else begin
            draw_filled_rect(frame_buffer, coord_x, coord_y, dim_x, width, color);
            draw_filled_rect(frame_buffer, coord_x, coord_y, width, dim_y, color);
            draw_filled_rect(frame_buffer, coord_x + dim_x - width, coord_y, width, dim_y, color);
            draw_filled_rect(frame_buffer, coord_x, coord_y + dim_y - width, dim_x, width, color);
            draw_rect = 0;
        end

    end

endfunction