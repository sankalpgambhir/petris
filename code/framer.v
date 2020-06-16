// framer implementation with frame buffer

module framer(
    input vsync,
    output reg [2:0] frame_out [0:9] [0:19],
    input reg [2:0] frame_buffer [0:9] [0:19]
    );

    // public :

    // frame buffer with asynchronous public access
    // using externally managed buffer
    //reg [2:0] frame_buffer [0:9] [0:19];

    // mutex for access control
    // not using public access buffer drawing right now
    //reg frame_buffer_lock;

    // private :
    // not using buffer clear right now
    //integer i, j;

    initial begin
        //frame_buffer_lock = 0; // unlocked
    end

    // reset and write frame buffer on screen end
    always @(posedge vsync) begin
        frame_out <= frame_buffer;
        /*
        for (i = 0; i < 10; i = i + 1) begin
            for (j = 0; j < 20; i = j + 1) begin
                frame_buffer[i][j] <= 3'b000;
            end
        end
        */
    end



endmodule
