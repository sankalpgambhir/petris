// initialize ROM and make available for access
// usage: rom.MODULE

// note: I have not tested loading 2D arrays and I'm totally hoping
// that this works with no basis whatsoever

module rom(
    output reg [15:0] GLYPH_ROM [0:255][0:7] // GR [ascii] [x] [y]
    );
    initial begin
        $readmemh("glyph.rom", GLYPH_ROM); // glyphs for printing
    end
endmodule