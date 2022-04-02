
module video_timing
(
    input       clk,
    input       clk_pix,
    input       reset,

    output [8:0] hc,
    output [8:0] vc,

    output reg  hsync,
    output reg  vsync,
    
    output reg  hbl,
    output reg  vbl
);

// 224x256 timings

//hbstart	256
//height	224
//htotal	382
//refresh	59.949642
//vbend	    16
//vbstart	240
//vtotal	262
//width	    256

// 8MHz
wire [8:0] HBL_START  = 256;
wire [8:0] HS_START   = 336;
wire [8:0] HS_END     = 376;
wire [8:0] HTOTAL     = 511;

//wire [8:0] VBL_START  = 224;
//wire [8:0] VS_START   = 225;
//wire [8:0] VS_END     = 248;
//wire [8:0] VTOTAL     = 256;

wire [8:0] VBL_START  = 239;
wire [8:0] VBL_END    = 16;
wire [8:0] VS_START   = 4;
wire [8:0] VS_END     = 8;
wire [8:0] VTOTAL     = 256;


// 4MHz
//wire [8:0] HBL_START  = 256;
//wire [8:0] HS_START   = 256;
//wire [8:0] HS_END     = 258;
//wire [8:0] HTOTAL     = 264;
//
//wire [8:0] VBL_START  = 224;
//wire [8:0] VS_START   = 232;
//wire [8:0] VS_END     = 236;
//wire [8:0] VTOTAL     = 256;

reg [8:0] v;
reg [8:0] h;

assign vc = v;
assign hc = h;

assign hsync = ( h >= HS_START && h < HS_END );
assign vsync = ( v >= VS_START && v < VS_END );

always @ (posedge clk) begin
	if (reset) begin
		h <= 0;
		v <= 0;

		hbl <= 0;
		vbl <= 0;
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
end

endmodule


