// framer implementation with frame buffer

module framer(
    output reg [2:0] frame_out [0:799] [0:524]
    );

    // public :

    // frame buffer with asynchronous public access
    reg [2:0] frame_buffer [0:799] [0:524];

    // mutex for access control
    reg frame_buffer_lock;

    // private :

    initial begin
        frame_buffer_lock = 0; // unlocked
    end

    // reset and write frame buffer on screen end
    always @(posedge vsync) begin
        frame_out <= frame_buffer

        for (i = 0; i < 640; i = i + 1) begin
            for (j = 0; j < 480; i = j + 1) begin
                frame_buffer[i][j] <= 3'b000;
            end
        end
    end



endmodule
