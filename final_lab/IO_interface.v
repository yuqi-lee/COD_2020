module IO_interface
    (
        input sel,
        input reg [31:0] DOR,


        output [15:0] data,
        output  is_ready,
        output reg [31:0] DIR,
        output reg [31:0] CR,
        output reg [31:0] SR

    );

    