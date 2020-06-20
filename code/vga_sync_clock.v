// VGA runs at 25.2 MHz with our config 
// 800 * 525 * 60 Hz = 25 200 000
// we use an approximate 25 MHz clock for display elements
// to achieve a frame rate of about 59.52 Hz

module vga_sync_clock(
    input reg clock,
    output reg vga_clock    
    );

    // clock assumed to be running at 1 GHz
    // we have a multiplier of 40
    // multiplier reduced due to performance issues
    localparam multiplier = 2;

    integer counter;

    initial begin
        counter = 0;
        vga_clock = clock;
    end
    
    always @(posedge clock) begin
        counter <= counter + 1;
        if (counter == multiplier) begin
            counter <= 0;
            vga_clock <= ~vga_clock;
        end
    end

endmodule