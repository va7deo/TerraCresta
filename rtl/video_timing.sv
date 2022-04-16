
module video_timing
(
    input       clk,
    input       clk_pix,
    input       reset,

    input  signed [3:0] hs_offset,
    input  signed [3:0] vs_offset,

    output [8:0] hc,
    output [8:0] vc,

    output reg  hsync,
    output reg  vsync,
    
    output reg  hbl,
    output reg  vbl 
);

// 6MHz
wire [8:0] HBL_START  = 256;
wire [8:0] HS_START   = 296;
wire [8:0] HS_END     = 328;
wire [8:0] HTOTAL     = 383;

wire [8:0] VBL_START  = 223;
wire [8:0] VBL_END    = 263;
wire [8:0] VS_START   = 240;
wire [8:0] VS_END     = 248;
wire [8:0] VTOTAL     = 263;

reg [8:0] v;
reg [8:0] h;

assign vc = v;
assign hc = h;

//assign hsync = ( h >= (HS_START + $signed(hs_offset)) && h < (HS_END + $signed(hs_offset)) );
//assign vsync = ( v >= (VS_START + $signed(vs_offset)) && v < (VS_END + $signed(vs_offset)) );

always @ (posedge clk) begin
	if (reset) begin
		h <= 0;
		v <= 0;

		hbl <= 0;
		vbl <= 0;

        hsync <= 0;
        vsync <= 0;
	end else if ( clk_pix == 1 ) begin 
	// counter
    if (h == HTOTAL) begin
        h <= 0;
        hbl <= 0;

        v <= v + 1'd1;                

        if ( v == VTOTAL-1 ) begin
            v <= 0;
        end

        end else begin
            h <= h + 1'd1;
        end

        // h signals
        if ( h == HBL_START-1 ) begin
            hbl <= 1;
        end 

        // v signals
        if ( v == VBL_START ) begin
            vbl <= 1;
        end else if ( v == VBL_END-1 ) begin
            vbl <= 0;
        end
    end
   
    if ( v == (VS_START + $signed(vs_offset) ) ) begin
        vsync <= 1;
    end else if ( v == (VS_END + $signed(vs_offset) ) ) begin
        vsync <= 0;
    end

    if ( h == (HS_START + $signed(hs_offset) ) ) begin
        hsync <= 1;
    end else if ( h == (HS_END + $signed(hs_offset) ) ) begin
        hsync <= 0;
    end

end

endmodule


