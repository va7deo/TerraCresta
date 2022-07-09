//============================================================================
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//
//============================================================================

`default_nettype none

module emu
(
    //Master input clock
    input         CLK_50M,

    //Async reset from top-level module.
    //Can be used as initial reset.
    input         RESET,

    //Must be passed to hps_io module
    inout  [48:0] HPS_BUS,

    //Base video clock. Usually equals to CLK_SYS.
    output        CLK_VIDEO,

    //Enable Y/C output
`ifdef MISTER_ENABLE_YC
    output [39:0] CHROMA_PHASE_INC,
    output        YC_EN,
    output        PALFLAG,
`endif

    //Multiple resolutions are supported using different CE_PIXEL rates.
    //Must be based on CLK_VIDEO
    output        CE_PIXEL,

    //Video aspect ratio for HDMI. Most retro systems have ratio 4:3.
    //if VIDEO_ARX[12] or VIDEO_ARY[12] is set then [11:0] contains scaled size instead of aspect ratio.
    output [12:0] VIDEO_ARX,
    output [12:0] VIDEO_ARY,

    output  [7:0] VGA_R,
    output  [7:0] VGA_G,
    output  [7:0] VGA_B,
    output        VGA_HS,
    output        VGA_VS,
    output        VGA_DE,    // = ~(VBlank | HBlank)
    output        VGA_F1,
    output [2:0]  VGA_SL,
    output        VGA_SCALER, // Force VGA scaler

    input  [11:0] HDMI_WIDTH,
    input  [11:0] HDMI_HEIGHT,
    output        HDMI_FREEZE,

`ifdef MISTER_FB
    // Use framebuffer in DDRAM (USE_FB=1 in qsf)
    // FB_FORMAT:
    //    [2:0] : 011=8bpp(palette) 100=16bpp 101=24bpp 110=32bpp
    //    [3]   : 0=16bits 565 1=16bits 1555
    //    [4]   : 0=RGB  1=BGR (for 16/24/32 modes)
    //
    // FB_STRIDE either 0 (rounded to 256 bytes) or multiple of pixel size (in bytes)
    output        FB_EN,
    output  [4:0] FB_FORMAT,
    output [11:0] FB_WIDTH,
    output [11:0] FB_HEIGHT,
    output [31:0] FB_BASE,
    output [13:0] FB_STRIDE,
    input         FB_VBL,
    input         FB_LL,
    output        FB_FORCE_BLANK,

`ifdef MISTER_FB_PALETTE
    // Palette control for 8bit modes.
    // Ignored for other video modes.
    output        FB_PAL_CLK,
    output  [7:0] FB_PAL_ADDR,
    output [23:0] FB_PAL_DOUT,
    input  [23:0] FB_PAL_DIN,
    output        FB_PAL_WR,
`endif
`endif

    output        LED_USER,  // 1 - ON, 0 - OFF.

    // b[1]: 0 - LED status is system status OR'd with b[0]
    //       1 - LED status is controled solely by b[0]
    // hint: supply 2'b00 to let the system control the LED.
    output  [1:0] LED_POWER,
    output  [1:0] LED_DISK,

    // I/O board button press simulation (active high)
    // b[1]: user button
    // b[0]: osd button
    output  [1:0] BUTTONS,

    input         CLK_AUDIO, // 24.576 MHz
    output [15:0] AUDIO_L,
    output [15:0] AUDIO_R,
    output        AUDIO_S,   // 1 - signed audio samples, 0 - unsigned
    output  [1:0] AUDIO_MIX, // 0 - no mix, 1 - 25%, 2 - 50%, 3 - 100% (mono)

    //ADC
    inout   [3:0] ADC_BUS,

    //SD-SPI
    output        SD_SCK,
    output        SD_MOSI,
    input         SD_MISO,
    output        SD_CS,
    input         SD_CD,

    //High latency DDR3 RAM interface
    //Use for non-critical time purposes
    output        DDRAM_CLK,
    input         DDRAM_BUSY,
    output  [7:0] DDRAM_BURSTCNT,
    output [28:0] DDRAM_ADDR,
    input  [63:0] DDRAM_DOUT,
    input         DDRAM_DOUT_READY,
    output        DDRAM_RD,
    output [63:0] DDRAM_DIN,
    output  [7:0] DDRAM_BE,
    output        DDRAM_WE,

    //SDRAM interface with lower latency
    output        SDRAM_CLK,
    output        SDRAM_CKE,
    output [12:0] SDRAM_A,
    output  [1:0] SDRAM_BA,
    inout  [15:0] SDRAM_DQ,
    output        SDRAM_DQML,
    output        SDRAM_DQMH,
    output        SDRAM_nCS,
    output        SDRAM_nCAS,
    output        SDRAM_nRAS,
    output        SDRAM_nWE,

`ifdef MISTER_DUAL_SDRAM
    //Secondary SDRAM
    //Set all output SDRAM_* signals to Z ASAP if SDRAM2_EN is 0
    input         SDRAM2_EN,
    output        SDRAM2_CLK,
    output [12:0] SDRAM2_A,
    output  [1:0] SDRAM2_BA,
    inout  [15:0] SDRAM2_DQ,
    output        SDRAM2_nCS,
    output        SDRAM2_nCAS,
    output        SDRAM2_nRAS,
    output        SDRAM2_nWE,
`endif

    input         UART_CTS,
    output        UART_RTS,
    input         UART_RXD,
    output        UART_TXD,
    output        UART_DTR,
    input         UART_DSR,

    // Open-drain User port.
    // 0 - D+/RX
    // 1 - D-/TX
    // 2..6 - USR2..USR6
    // Set USER_OUT to 1 to read from USER_IN.
    input   [6:0] USER_IN,
    output  [6:0] USER_OUT,

    input         OSD_STATUS
);

///////// Default values for ports not used in this core /////////

assign ADC_BUS  = 'Z;
assign USER_OUT = '1;
assign {UART_RTS, UART_TXD, UART_DTR} = 0;
assign {SD_SCK, SD_MOSI, SD_CS} = 'Z;
assign {SDRAM_DQ, SDRAM_A, SDRAM_BA, SDRAM_CLK, SDRAM_CKE, SDRAM_DQML, SDRAM_DQMH, SDRAM_nWE, SDRAM_nCAS, SDRAM_nRAS, SDRAM_nCS} = 'Z;
//assign {DDRAM_CLK, DDRAM_BURSTCNT, DDRAM_ADDR, DDRAM_DIN, DDRAM_BE, DDRAM_RD, DDRAM_WE} = '0;  

//assign VGA_SL = 0;
assign VGA_F1 = 0;
assign VGA_SCALER = 0;
assign HDMI_FREEZE = 0;

assign AUDIO_MIX = 0;
assign LED_USER = reset & m68k_a[0] & | sprite_tile ;
assign LED_DISK = 0;
assign LED_POWER = 0;
assign BUTTONS = 0;

// Status Bit Map:
//              Upper                          Lower                
// 0         1         2         3          4         5         6   
// 01234567890123456789012345678901 23456789012345678901234567890123
// 0123456789ABCDEFGHIJKLMNOPQRSTUV 0123456789ABCDEFGHIJKLMNOPQRSTUV
// X X XXX XXXX         XXXXXXXXXXX XXXXXXX                         

wire [1:0] aspect_ratio = status[9:8];
wire orientation = ~status[10];
wire [2:0] scan_lines = status[6:4];
wire [3:0] hs_offset = status[27:24];
wire [3:0] vs_offset = status[31:28];

wire test_flip_x = status[32];
wire test_flip_y = status[33];
wire fg_enable   = ~(status[36] | key_fg_enable);
wire bg_enable   = ~(status[37] | key_bg_enable);
wire spr_enable  = ~(status[38] | key_spr_enable);

assign VIDEO_ARX = (!aspect_ratio) ? (orientation  ? 8'd4 : 8'd3) : (aspect_ratio - 1'd1);
assign VIDEO_ARY = (!aspect_ratio) ? (orientation  ? 8'd3 : 8'd4) : 12'd0;

`include "build_id.v" 
localparam CONF_STR = {
    "Terra Cresta;;",
    "-;",
    "P1,Video Settings;",
    "P1-;",
    "P1O89,Aspect ratio,Original,Full Screen,[ARC1],[ARC2];",
    "P1OA,Orientation,Horz,Vert;",
    "P1-;",
    "P1O46,Scandoubler Fx,None,HQ2x,CRT 25%,CRT 50%,CRT 75%,CRT 100%;",
    "P1OB,Force Scandoubler,Off,On;",
    "P1-;",
    "P1O2,Video Mode,NTSC,PAL;",
    "P1OL,Video Signal,RGBS/YPbPr,Y/C;",
    "P1-;",
    "P1OOR,H-sync Adjust,0,1,2,3,4,5,6,7,-8,-7,-6,-5,-4,-3,-2,-1;",
    "P1OSV,V-sync Adjust,0,1,2,3,4,5,6,7,-8,-7,-6,-5,-4,-3,-2,-1;",
    "P2-;",
    "P2,Pause Options;",
    "P2OM,Pause when OSD is open,Off,On;",
    "P2ON,Dim video after 10s,Off,On;",
    "-;",
    "P3,PCB & Debug Settings;",
    "P3-;",
    "P3o2,Turbo (Amazon Sets),Off,On;",
    "P3o3,Service Menu,Off,On;",
    "P3-;",
    "P3o5,Foreground Layer,On,Off;",
    "P3o4,Background Layer,On,Off;",
    "P3o6,Sprites,On,Off;",
    "P3-;",
    "P3o0,Invert Sprite X-Axis,Off,On;",
    "P3o1,Invert Sprite Y-Axis,Off,On;",
    "DIP;",
    "-;",
    "R0,Reset;",
    "J1,Button 1,Button 2,Button 3,Start,Coin,Pause;",
    "jn,A,B,X,R,L,Start;",           // name mapping
    "V,v",`BUILD_DATE
};

wire hps_forced_scandoubler;
wire forced_scandoubler = hps_forced_scandoubler | status[11];
wire  [1:0] buttons;
wire [63:0] status;
wire [10:0] ps2_key;
wire [15:0] joy0, joy1;

hps_io #(.CONF_STR(CONF_STR)) hps_io
(
    .clk_sys(clk_sys),
    .HPS_BUS(HPS_BUS),

    .buttons(buttons),
    .ps2_key(ps2_key),
    .status(status),
    .status_menumask(direct_video),
    .forced_scandoubler(hps_forced_scandoubler),
    .gamma_bus(gamma_bus),
    .direct_video(direct_video),
    .video_rotated(video_rotated),

    .ioctl_download(ioctl_download),
    .ioctl_upload(ioctl_upload),
    .ioctl_wr(ioctl_wr),
    .ioctl_addr(ioctl_addr),
    .ioctl_dout(ioctl_dout),
    .ioctl_din(ioctl_din),
    .ioctl_index(ioctl_index),
    .ioctl_wait(ioctl_wait),

    .joystick_0(joy0),
    .joystick_1(joy1)
);

// INPUT

// 8 dip switches of 8 bits
reg [7:0] sw[8];
always @(posedge clk_sys) begin
    if (ioctl_wr && (ioctl_index==254) && !ioctl_addr[24:3]) begin
        sw[ioctl_addr[2:0]] <= ioctl_dout;
    end
end

wire        direct_video;

wire        ioctl_download;
wire        ioctl_upload;
wire        ioctl_upload_req;
wire        ioctl_wait;
wire        ioctl_wr;
wire  [7:0] ioctl_index;
wire [24:0] ioctl_addr;
wire  [7:0] ioctl_dout;
wire  [7:0] ioctl_din;

wire [21:0] gamma_bus;

//<buttons names="Fire,Jump,Start,Coin,Pause" default="A,B,R,L,Start" />
reg [15:0] p1 ;
reg [15:0] p2 ;
reg [15:0] dsw1 ;
reg [15:0] sys ;

//localparam pcb_terra_cresta = 0;
//localparam pcb_amazon       = 1;
//localparam pcb_horekid      = 2;
//localparam pcb_amazont      = 3;
//localparam pcb_horekidb2    = 4;

always @ (posedge clk_sys) begin
    p1 <= 16'hffff;
    p1[5:0] <= ~{ p1_buttons[1:0], p1_right, p1_left ,p1_down, p1_up};
     
    p2 <= 16'hffff;
    p2[5:0] <= ~{ p2_buttons[1:0], p2_right, p2_left ,p2_down, p2_up};
    
    sys <= 16'hffff;
    if ( pcb == 0 || pcb == 2 ) begin
        // terracre and horekid
        // PORT_BIT( 0x0100, IP_ACTIVE_LOW, IPT_START1 )
        // PORT_BIT( 0x0200, IP_ACTIVE_LOW, IPT_START2 )
        sys[8] <= ~(p1_start1 | p2_start1) ; // coin [5]
        sys[9] <= ~(p1_start2 | p2_start2) ;
    end else begin
        // amatelas, amazon, amazont and horekidb2
        // PORT_BIT( 0x0100, IP_ACTIVE_LOW, IPT_START2 )
        // PORT_BIT( 0x0200, IP_ACTIVE_LOW, IPT_START1 )
        sys[8] <= ~(p1_start2 | p2_start2) ; // coin [5]
        sys[9] <= ~(p1_start1 | p2_start1) ;
    end
    sys[10] <= ~p1_coin ;
    sys[11] <= ~p2_coin ;
    
    if ( pcb == 0 || pcb == 1 || pcb == 3 ) begin
        // terracre / amazon
        sys[13] <= ~(sw[3][5] | service | key_test) ;
        sys[12] <= ~key_service;
    end else begin
        // horekid
        sys[13] <= ~(service | key_test) ;
        sys[12] <= ~key_service;
    end
    
    dsw1 <= { sw[1], { ( sw[0][7] & ~status[34] ), sw[0][6:0] } };
end

wire       p1_up      = joy0[3] | key_p1_up;
wire       p1_down    = joy0[2] | key_p1_down;
wire       p1_left    = joy0[1] | key_p1_left;
wire       p1_right   = joy0[0] | key_p1_right;
wire [1:0] p1_buttons = joy0[5:4] | {key_p1_b, key_p1_a};

wire       p2_up      = joy1[3] | key_p2_up;
wire       p2_down    = joy1[2] | key_p2_down;
wire       p2_left    = joy1[1] | key_p2_left;
wire       p2_right   = joy1[0] | key_p2_right;
wire [1:0] p2_buttons = joy1[5:4] | {key_p2_b, key_p2_a};

wire p1_start1     = joy0[6] | key_p1_start;
wire p1_start2     = joy0[7] | key_p2_start | status[34];
wire p1_coin       = joy0[8] | key_p1_coin;
wire b_pause       = joy0[9] | joy1[9] | key_pause;
wire service       = joy0[10] | key_test | status[35];

wire p2_start1 = joy1[6] | key_p1_start;
wire p2_start2 = joy1[7] | key_p2_start;
wire p2_coin   = joy1[8] | key_p2_coin;

// Keyboard handler

wire key_p1_start, key_p2_start, key_p1_coin, key_p2_coin;
wire key_test, key_reset, key_service, key_pause;
wire key_fg_enable, key_bg_enable, key_spr_enable;

wire key_p1_up, key_p1_left, key_p1_down, key_p1_right, key_p1_a, key_p1_b;
wire key_p2_up, key_p2_left, key_p2_down, key_p2_right, key_p2_a, key_p2_b;

wire pressed = ps2_key[9];

always @(posedge clk_sys) begin
    reg old_state;

    old_state <= ps2_key[10];
    if(old_state ^ ps2_key[10]) begin
        casex(ps2_key[8:0])
            'h016: key_p1_start   <= pressed; // 1
            'h01e: key_p2_start   <= pressed; // 2
            'h02E: key_p1_coin    <= pressed; // 5
            'h036: key_p2_coin    <= pressed; // 6
            'h006: key_test       <= key_test ^ pressed; // f2
            'h004: key_reset      <= pressed; // f3
            'h046: key_service    <= pressed; // 9
            'h04D: key_pause      <= pressed; // p

            'hX75: key_p1_up      <= pressed; // up
            'hX72: key_p1_down    <= pressed; // down
            'hX6b: key_p1_left    <= pressed; // left
            'hX74: key_p1_right   <= pressed; // right
            'h014: key_p1_a       <= pressed; // lctrl
            'h011: key_p1_b       <= pressed; // lalt

            'h02d: key_p2_up      <= pressed; // r
            'h02b: key_p2_down    <= pressed; // f
            'h023: key_p2_left    <= pressed; // d
            'h034: key_p2_right   <= pressed; // g
            'h01c: key_p2_a       <= pressed; // a
            'h01b: key_p2_b       <= pressed; // s

            'h083: key_fg_enable  <= key_fg_enable ^ pressed; // f7
            'h00A: key_bg_enable  <= key_bg_enable ^ pressed; // f8
            'h001: key_spr_enable <= key_spr_enable ^ pressed; // f9
        endcase
    end
end

// PAUSE SYSTEM
wire    pause_cpu;
wire    hs_pause;


// 8 bits per colour, 72MHz sys clk
pause #(8,8,8,72) pause 
(
    .clk_sys(clk_sys),
    .reset(reset),
    .user_button(b_pause),
    .pause_request(hs_pause),
    .options(status[23:22]),
    .pause_cpu(pause_cpu),
    .dim_video(dim_video),
    .OSD_STATUS(OSD_STATUS),
    .r(rgb[23:16]),
    .g(rgb[15:8]),
    .b(rgb[7:0]),
    .rgb_out(rgb_pause_out)
);

wire [23:0] rgb_pause_out;
wire dim_video;


reg user_flip;

wire pll_locked;

wire clk_sys;
reg  clk_4M,clk_8M,clk_6M,clk_16M,clk_ym;

pll pll
(
    .refclk(CLK_50M),
    .rst(0),
    .outclk_0(clk_sys),     // 96
    .locked(pll_locked)
);

reg [5:0] clk16_count;
reg [5:0] clk8_count;
reg [5:0] clk4_count;
reg [5:0] clk6_count;
reg [15:0] clk_ym_count;

always @ (posedge clk_sys) begin
   
    clk_16M <= ( clk16_count == 0 );

    if ( clk16_count == 5 ) begin
        clk16_count <= 0;
    end else begin
        clk16_count <= clk16_count + 1; 
    end

    clk_8M <= ( clk8_count == 0 );

    if ( clk8_count == 11 ) begin
        clk8_count <= 0;
    end else begin
        clk8_count <= clk8_count + 1;
    end

    clk_4M <= ( clk4_count == 0 );

    if ( clk4_count == 23 ) begin
        clk4_count <= 0;
    end else begin
        clk4_count <= clk4_count + 1;
    end
    
    clk_6M <= ( clk6_count == 0 );

    if ( clk6_count == 15 ) begin
        clk6_count <= 0;
    end else begin
        clk6_count <= clk6_count + 1;
    end    
     
    clk_ym <= ( clk_ym_count == 0 );

    if ( clk_ym_count == 12287 ) begin  // 4MHz / 512 = 7.8KHz
        clk_ym_count <= 0;
    end else begin
        clk_ym_count <= clk_ym_count + 1;
    end
     
end

wire    reset;
assign  reset = RESET | status[0] | key_reset;

//////////////////////////////////////////////////////////////////
wire rotate_ccw = 1;
wire no_rotate = orientation | direct_video;
wire video_rotated ;
wire flip = 0;

reg [23:0]     rgb;

wire hbl;
wire vbl;

wire [8:0] hc;
wire [8:0] vc;

wire hsync;
wire vsync;

//reg hbl_delay;
//reg vbl_delay;
//reg hsync_delay;
//reg vsync_delay;
//
//// 4 clock pipeline to make pixel
//always @ (posedge clk_sys) begin
//    if ( clk_4M == 1 ) begin
//        hbl_delay <= hbl;
//        vbl_delay <= vbl;
//
//        hsync_delay <= hsync;
//        vsync_delay <= vsync;
//    end
//end
wire hbl_delay, vbl_delay;

delay delay_hbl( .clk(clk_6M), .i( hbl ), .o(hbl_delay) ) ;
delay delay_vbl( .clk(clk_6M), .i( vbl ), .o(vbl_delay) ) ;

wire [8:0] vc_raw;
assign vc = vc_raw + 16; 

video_timing video_timing (
    .clk(clk_sys),
    .clk_pix(clk_6M),
    .hc(hc),
    .vc(vc_raw),
    .hs_offset(hs_offset),
    .vs_offset(vs_offset),
    .hbl(hbl),
    .vbl(vbl),
    .hsync(hsync),
    .vsync(vsync)
);

screen_rotate screen_rotate (.*);

arcade_video #(256,24) arcade_video
(
        .*,

        .clk_video(clk_sys),
        .ce_pix(clk_6M),

        .RGB_in(rgb_pause_out),

        .HBlank(hbl_delay),
        .VBlank(vbl_delay),
        .HSync(hsync),
        .VSync(vsync),

        .fx(scan_lines)
);

/* 	Phase Accumulator Increments (Fractional Size 32, look up size 8 bit, total 40 bits)
    Increment Calculation - (Output Clock * 2 ^ Word Size) / Reference Clock
    Example
    NTSC = 3.579545
    W = 40 ( 32 bit fraction, 8 bit look up reference)
    Ref CLK = 42.954544 (This could us any clock)

    NTSC_Inc = 3.579545333 * 2 ^ 40 / 96 = 40997413706
*/

// SET PAL and NTSC TIMING
`ifdef MISTER_ENABLE_YC
    assign CHROMA_PHASE_INC = PALFLAG ? 40'd50779326758 : 40'd40997477092;
    assign YC_EN =  status[21];
    assign PALFLAG = status[2];
`endif

wire [11:0] spr_pix = sprite_line_buffer[hc];

// prom_s = idx 
//wire [7:0]  spr_col_idx = spr_pix[3:0];

wire [7:0] spi = { 2'b10, ( ( spr_pix[3] == 1'b0 ) ? spr_pix[9:8] : spr_pix[11:10] ), prom_s[ spr_pix[7:0] ][3:0] };  //p[3:0];

wire  [9:0] hc_s = flip ? ~hc[7:0] + scroll_x + 9'd256 : hc[7:0] + scroll_x ;
wire  [8:0] vc_s = flip ? ~vc[7:0] + scroll_y + 9'd256 : vc[7:0] + scroll_y;

wire  [8:0] hc_x = {hc[8], hc[7:0] ^ {8{flip}}};
wire  [8:0] vc_x = vc ^ {9{flip}};

reg  [3:0] gfx1_pix ;
reg  [7:0] gfx2_pix ;

wire [11:0] bg_tile = { hc_s[9:4], vc_s[8:4] };
wire  [9:0] fg_tile = {   hc[7:3],   vc[7:3] };

reg [7:0] pal_idx;

always @ ( clk_6M ) begin
    rgb <=  { prom_r[pal_idx], 4'b0, prom_g[pal_idx], 4'b0, prom_b[pal_idx], 4'b0 } ;
end


reg [7:0] gfxc ;


reg [15:0] fg_ram_dout_buf;
reg [15:0] bg_ram_dout_buf;

wire     [7:0] gfx1_dout;
wire     [7:0] gfx2_dout;
wire    [63:0] gfx3_dout;

// tile attributes
assign bg_ram_addr = bg_tile ;
assign fg_ram_addr = fg_tile ;

reg    [13:0] gfx1_addr;
reg    [16:0] gfx2_addr;

reg [8:0] hc_r;
reg [8:0] hc_s_r;
reg [1:0] gfx2_pal_h;
reg [1:0] gfx2_pal_l;
    
always @ (posedge clk_sys) begin
    if ( reset == 1 ) begin

    end else if ( clk_6M == 1 ) begin
    // 0
        //gfx1_addr <= { ( (pcb == 0 ) ? 1'b0 : fg_ram_dout[8] ) , fg_ram_dout[7:0],   vc[2:0],   hc[2:1] } ;  // tile #.  set of 256 tiles -- fg_ram_dout[7:0]
        gfx1_addr <= { 1'b0 , fg_ram_dout[7:0],   vc[2:0],   hc[2:1] } ;  // tile #.  set of 256 tiles -- fg_ram_dout[7:0]
        
        gfx2_addr <= { bg_ram_dout[9:0], vc_s[3:0], hc_s[3:1] } ;
        
        gfx2_pal_h  <= bg_ram_dout[14:13];
        gfx2_pal_l  <= bg_ram_dout[12:11];
        
        hc_r <= hc;
        hc_s_r <= hc_s;

        // latch tile attributes
        bg_ram_dout_buf <= bg_ram_dout;
    // 1
        gfx1_pix <= ( hc_r[0] == 0 ) ? gfx1_dout[3:0] : gfx1_dout[7:4];

        gfx2_pix <= { 2'b11 , ((gfx2_pen[3] == 0 ) ? gfx2_pal_l : gfx2_pal_h ), gfx2_pen } ;
        
    // 2
        pal_idx <= ( gfx1_pix < 4'hf && fg_enable ) ? { 4'b0, gfx1_pix } : ( spr_enable == 0 || ( bg_enable == 1 && spr_pix == sprite_trans_pen && scroll_x[13] == 0 )) ? gfx2_pix :  spi ;        
    end
end
    
wire [3:0] gfx2_pen ;
assign gfx2_pen = ((   hc_s_r[0] == 0 ) ? gfx2_dout[3:0] : gfx2_dout[7:4] )    ;
    
/// 68k cpu

always @ (posedge clk_sys) begin

    if ( reset == 1 ) begin
        m68k_dtack_n <= 1;
    end else if ( clk_16M == 1 ) begin
        // tell 68k to wait for valid data. 0=ready 1=wait
        // always ack when it's not program rom
        m68k_dtack_n <= 0; 

        // select cpu data input based on what is active 
        m68k_din <=  prog_rom_cs  ? prog_rom_data :
                     m68k_ram_cs  ? ram68k_dout :
                     m68k_ram1_cs ? m68k_ram1_dout :
                     input_p1_cs ? p1 :
                     input_p2_cs ? p2 :
                     input_system_cs ? sys:
                     input_dsw_cs ? dsw1 :
                     prot_chip_data_cs ? { 8'h00, nb1412m2_decrypt_dout }:
                     16'd0;
    end
end 

// Chip select mux
// M68K selects
wire prog_rom_cs;
wire m68k_ram_cs;
wire bg_ram_cs;
wire m68k_ram1_cs;
wire fg_ram_cs;

wire input_p1_cs;
wire input_p2_cs;
wire input_system_cs;
wire input_dsw_cs;

wire flip_cs;
wire scroll_x_cs;
wire scroll_y_cs;

wire sound_latch_cs;

wire prot_chip_data_cs;
wire prot_chip_cmd_cs;

// Z80 selects
wire z80_rom_cs;
wire z80_ram_cs;

wire z80_sound0_cs;
wire z80_sound1_cs;
wire z80_dac1_cs;
wire z80_dac2_cs;
wire z80_latch_clr_cs;
wire z80_latch_r_cs;

// Select PCB Title and set chip select lines
reg [2:0] pcb;
reg [15:0] scroll_x;
reg [15:0] scroll_y;
reg [7:0]  sound_latch;

always @(posedge clk_sys)
    if (ioctl_wr && (ioctl_index==1))
        pcb <= ioctl_dout;

chip_select cs (
    .pcb(pcb),

    .m68k_a(m68k_a),
    .m68k_as_n(m68k_as_n),

    .z80_addr(z80_addr),
    .MREQ_n(MREQ_n),
    .IORQ_n(IORQ_n),
    .M1_n(M1_n),

    // M68K selects
    .prog_rom_cs(prog_rom_cs),
    .m68k_ram_cs(m68k_ram_cs),
    .bg_ram_cs(bg_ram_cs),
    .m68k_ram1_cs(m68k_ram1_cs),
    .fg_ram_cs(fg_ram_cs),

    .input_p1_cs(input_p1_cs),
    .input_p2_cs(input_p2_cs),
    .input_system_cs(input_system_cs),
    .input_dsw_cs(input_dsw_cs),

    .flip_cs(flip_cs),
    .scroll_x_cs(scroll_x_cs),
    .scroll_y_cs(scroll_y_cs),

    .sound_latch_cs(sound_latch_cs),

    .prot_chip_data_cs(prot_chip_data_cs),
    .prot_chip_cmd_cs(prot_chip_cmd_cs),

    // Z80 selects
    .z80_rom_cs(z80_rom_cs),
    .z80_ram_cs(z80_ram_cs),

    .z80_sound0_cs(z80_sound0_cs),
    .z80_sound1_cs(z80_sound1_cs),
    .z80_dac1_cs(z80_dac1_cs),
    .z80_dac2_cs(z80_dac2_cs),
    .z80_latch_clr_cs(z80_latch_clr_cs),
    .z80_latch_r_cs(z80_latch_r_cs)
);

// CPU outputs
wire m68k_rw         ;    // Read = 1, Write = 0
wire m68k_as_n       ;    // Address strobe
wire m68k_lds_n      ;    // Lower byte strobe
wire m68k_uds_n      ;    // Upper byte strobe
wire m68k_E;         
wire [2:0] m68k_fc    ;   // Processor state
wire m68k_reset_n_o  ;    // Reset output signal
wire m68k_halted_n   ;    // Halt output

// CPU busses
wire [15:0] m68k_dout       ;
wire [23:0] m68k_a          ;
reg  [15:0] m68k_din        ;   
assign m68k_a[0] = 1'b0;

// CPU inputs
reg  m68k_dtack_n ;         // Data transfer ack (always ready)
reg  m68k_ipl2_n ;


wire reset_n;
wire m68k_vpa_n = ~int_ack;//( m68k_lds_n == 0 && m68k_fc == 3'b111 ); // int ack

reg int_ack ;
reg [1:0] vbl_sr;

wire [3:0] sprite_trans_pen = (pcb == 0 || pcb == 1 || pcb == 3 ) ? 4'd0 : 4'd15;

// vblank handling 
// process interrupt and sprite buffering
always @ (posedge clk_sys ) begin
    if ( reset == 1 ) begin
        m68k_ipl2_n <= 1 ;
        int_ack <= 0;
    end else begin
        vbl_sr <= { vbl_sr[0], vbl };

        if ( clk_16M == 1 ) begin
            int_ack <= ( m68k_as_n == 0 ) && ( m68k_fc == 3'b111 ); // cpu acknowledged the interrupt
        end

        if ( vbl_sr == 2'b01 ) begin // rising edge
            // trigger sprite buffer copy
            copy_sprite_state <= 1;
            //  68k vbl interrupt
            m68k_ipl2_n <= 0;
        end else if ( int_ack == 1 || vbl_sr == 2'b10 ) begin
            // deassert interrupt since 68k ack'ed.
            m68k_ipl2_n <= 1 ;
        end
    end

    //   copy sprite list to dedicated sprite list ram
    // start state machine for copy
    if ( copy_sprite_state == 1 ) begin
        sprite_shared_addr <= 0;
        copy_sprite_state <= 2;
        sprite_buffer_addr <= 0;
    end else if ( copy_sprite_state == 2 ) begin
        // address now 0
        sprite_shared_addr <= sprite_shared_addr + 1 ;
        copy_sprite_state <= 3; 
    end else if ( copy_sprite_state == 3 ) begin        
       // address 0 result
        sprite_y_pos <= 239 - sprite_shared_ram_dout;

        sprite_shared_addr <= sprite_shared_addr + 1 ;
        copy_sprite_state <= 4; 
    end else if ( copy_sprite_state == 4 ) begin    
        // address 1 result
        sprite_tile[7:0] <= sprite_shared_ram_dout;

        sprite_shared_addr <= sprite_shared_addr + 1 ;
        copy_sprite_state <= 5; 
    end else if ( copy_sprite_state == 5 ) begin        
            // add 256 to x?
        sprite_x_256 <= sprite_shared_ram_dout[0];
        // add 256 to tile?

        if ( pcb == 0 || pcb == 1 || pcb == 3 ) begin
            sprite_tile[9:8] <= { 1'b0, sprite_shared_ram_dout[1] };
        end else begin
//			if( attrs&0x10 ) tile |= 0x100;
//			if( attrs&0x02 ) tile |= 0x200;
            sprite_tile[9:8] <= { sprite_shared_ram_dout[1], sprite_shared_ram_dout[4] };
        end
        
        // flip x?
        sprite_flip_x <= sprite_shared_ram_dout[2] ^ test_flip_x ;
        // flip y?
        sprite_flip_y <= sprite_shared_ram_dout[3] ^ test_flip_y ;
        // colour
        sprite_colour <= sprite_shared_ram_dout[7:4];

        sprite_shared_addr <= sprite_shared_addr + 1 ;

        copy_sprite_state <= 6; 
    end else if ( copy_sprite_state == 6 ) begin        
        sprite_x_pos <=  { sprite_x_256, sprite_shared_ram_dout } - 8'h7e ;

        copy_sprite_state <= 7; 
    end else if ( copy_sprite_state == 7 ) begin                
        sprite_buffer_w <= 1;
        sprite_buffer_din <= {sprite_tile,sprite_x_pos,sprite_y_pos,sprite_colour,sprite_flip_x,sprite_flip_y};
        
        copy_sprite_state <= 8;
    end else if ( copy_sprite_state == 8 ) begin                

        // write is complete
        sprite_buffer_w <= 0;
        // sprite has been buffered.  are we done?
        if ( sprite_buffer_addr < 8'h3f ) begin
            // start on next sprite
            sprite_buffer_addr <= sprite_buffer_addr + 1;
            copy_sprite_state <= 2;
        end else begin
            // we are done, go idle.  
            copy_sprite_state <= 0; 
        end
    end

    if ( draw_sprite_state == 0 && hc > 9'h0ff && next_y > 15  ) begin // 0xe0
        // clear sprite buffer
        sprite_x_ofs <= 0;
        draw_sprite_state <= 1;
        sprite_buffer_addr <= 0;
    end else if (draw_sprite_state == 1) begin
        sprite_line_buffer[sprite_x_ofs] <= sprite_trans_pen;  // 0
        if ( sprite_x_ofs < 255 ) begin
            sprite_x_ofs <= sprite_x_ofs + 1;
        end else begin
            // sprite buffer now blank
            draw_sprite_state <= 2;
        end
    end else if (draw_sprite_state == 2) begin        
        // get current sprite attributes
        {sprite_tile,sprite_x_pos,sprite_y_pos,sprite_colour,sprite_flip_x,sprite_flip_y} <= sprite_buffer_dout; //[34:0];
        draw_sprite_state <= 3;
        sprite_x_ofs <= 0;
    end else if (draw_sprite_state == 3) begin    
        draw_sprite_state <= 4;
    end else if (draw_sprite_state == 4) begin                
        draw_sprite_state <= 3; 
        if ( vc >= sprite_y_pos && vc < ( sprite_y_pos + 16 ) && sprite_x_pos < 256 ) begin
            // fetch bitmap 
            if ( p[3:0] != sprite_trans_pen ) begin
                sprite_line_buffer[sprite_x_pos] <= p;
            end
            if ( sprite_x_ofs < 15 ) begin
                sprite_x_pos <= sprite_x_pos + 1;
                sprite_x_ofs <= sprite_x_ofs + 1;
            end else begin
                draw_sprite_state <= 6;
            end
        end else begin
            draw_sprite_state <= 6;
        end
    end else if (draw_sprite_state == 6) begin                        
        // done. next sprite
        if ( sprite_buffer_addr < 63 ) begin
            sprite_buffer_addr <= sprite_buffer_addr + 1;
            draw_sprite_state <= 2;
        end else begin
            // all sprites done
            draw_sprite_state <= 7;
        end
    end else if (draw_sprite_state == 7) begin                        
        // we are done. wait for end of line
        if ( hc == 0 ) begin
            draw_sprite_state <= 0;
        end
    end
end

wire    [3:0] sprite_y_ofs = vc - sprite_y_pos ;

wire    [3:0] flipped_x = ( sprite_flip_x == 0 ) ? sprite_x_ofs : 15 - sprite_x_ofs;
wire    [3:0] flipped_y = ( sprite_flip_y == 0 ) ? sprite_y_ofs : 15 - sprite_y_ofs;

//wire    [3:0] gfx3_pix = (sprite_x_ofs[0] == 1 ) ? gfx3_dout[7:4] : gfx3_dout[3:0];
wire    [3:0] gfx3_pix = (flipped_x[0] == 1 ) ? gfx3_dout[7:4] : gfx3_dout[3:0];

// int spr_col = (u[t>>1]<<8) + (c<<4) + pen ;
// prom_u = palette bank lookup
wire   [11:0] p ;
wire   [16:0] gfx3_addr ;

always @ (*) begin
    if ( pcb == 0 || pcb == 1 || pcb == 3 ) begin
        // terra cresta / amazon
        gfx3_addr = { 1'b0, flipped_x[1], sprite_tile[8:0], flipped_y[3:0], flipped_x[3:2] };
        
        p = { prom_u[sprite_tile[8:1]][3:0], sprite_colour, gfx3_pix};
    end else begin
        // hori
        gfx3_addr = { flipped_x[1],       sprite_tile[9:0], flipped_y[3:0], flipped_x[3:2] };

        p = { prom_u[{sprite_tile[9],sprite_tile[7:2],sprite_tile[8]}][3:0], sprite_colour[3:1], 1'b0, gfx3_pix};
    end
end

// sprite_tile[9:8] <= { sprite_shared_ram_dout[1], sprite_shared_ram_dout[4] };

//		int tile = pSource[1]&0xff;
//		int attrs = pSource[2];
//		int flipx = attrs&0x04;
//		int flipy = attrs&0x08;
//		int color = (attrs&0xf0)>>4;
//		int sx = (pSource[3] & 0xff) - 0x80 + 256 * (attrs & 1);
//		int sy = 240 - (pSource[0] & 0xff);
//
//		if( transparent_pen )
//		{
//			int bank;
//
//			if( attrs&0x02 ) tile |= 0x200; // sprite_shared_ram_dout[1]
//			if( attrs&0x10 ) tile |= 0x100; // sprite_shared_ram_dout[4] 
//
//			bank = (tile&0xfc)>>1;
//			if( tile&0x200 ) bank |= 0x80; // sprite_shared_ram_dout[1]
//			if( tile&0x100 ) bank |= 0x01; // sprite_shared_ram_dout[4] 
//
//			color &= 0xe;
//			color += 16*(spritepalettebank[bank]&0xf);
//		}
//		else
//		{
//			if( attrs&0x02 ) tile|= 0x100;
//			color += 16 * (spritepalettebank[(tile>>1)&0xff] & 0x0f);
//		}

        



wire    [7:0] next_y ;
assign next_y = (vc+1'b1);

reg     [7:0] sprite_x_ofs;

reg    [11:0] sprite_line_buffer [255:0];

dual_port_ram #(.LEN(64), .DATA_WIDTH(64)) sprite_buffer (
    .clock_a ( clk_sys ),
    .address_a ( sprite_buffer_addr ),
    .wren_a ( 1'b0 ),
    .data_a ( ),
    .q_a ( sprite_buffer_dout ),
    
    .clock_b ( clk_sys ),
    .address_b ( sprite_buffer_addr ),
    .wren_b ( sprite_buffer_w ),
    .data_b ( sprite_buffer_din  ),
    .q_b( )

    );

        
reg  [3:0]  copy_sprite_state;
reg  [3:0]  draw_sprite_state;

wire [7:0]  sprite_shared_ram_dout;
reg  [7:0]  sprite_shared_addr;
reg  [5:0]  sprite_buffer_addr;  // 64 sprites
reg  [63:0] sprite_buffer_din;
wire [63:0] sprite_buffer_dout;
reg  sprite_buffer_w;

reg  [9:0]  sprite_tile ;  // terra cresta has 512 tiles ,  HORE HORE Kid has 1024
reg  [7:0]  sprite_y_pos;
reg  [8:0]  sprite_x_pos;
reg  [3:0]  sprite_colour;
reg  sprite_x_256;
reg  sprite_flip_x;
reg  sprite_flip_y;

// clock generation
reg  fx68_phi1 = 0; 

// phases for 68k clock
always @(posedge clk_sys) begin
    if ( clk_16M == 1 ) begin
        fx68_phi1 <= ~fx68_phi1; 
    end
end

fx68k fx68k (
    // input
    .clk( clk_16M ),
    .enPhi1(fx68_phi1),
    .enPhi2(!fx68_phi1),
    .extReset(reset),
    .pwrUp(reset),

    // output
    .eRWn(m68k_rw),
    .ASn( m68k_as_n),
    .LDSn(m68k_lds_n),
    .UDSn(m68k_uds_n),
    .E(),
    .VMAn(),
    .FC0(m68k_fc[0]),
    .FC1(m68k_fc[1]),
    .FC2(m68k_fc[2]),
    .BGn(),
    .oRESETn(m68k_reset_n_o),
    .oHALTEDn(m68k_halted_n),

    // input
    .VPAn( m68k_vpa_n ),  
    .DTACKn( m68k_dtack_n | pause_cpu ),     
    .BERRn(1'b1), 
    .BRn(1'b1),  
    .BGACKn(1'b1),
    
    .IPL0n(m68k_ipl2_n),
    .IPL1n(1'b1),
    .IPL2n(1'b1),

    // busses
    .iEdb(m68k_din),
    .oEdb(m68k_dout),
    .eab(m68k_a[23:1])
);

always @(posedge clk_sys) begin

        case ({flip, hc[2:0]})
            4'b0011: gfx1_dout <= gfx1_q[ 7: 0];
            4'b0101: gfx1_dout <= gfx1_q[15: 8];
            4'b0111: gfx1_dout <= gfx1_q[23:16];
            4'b0001: gfx1_dout <= gfx1_q[31:24];

            4'b1000: gfx1_dout <= gfx1_q[ 7: 0];
            4'b1110: gfx1_dout <= gfx1_q[15: 8];
            4'b1100: gfx1_dout <= gfx1_q[23:16];
            4'b1010: gfx1_dout <= gfx1_q[31:24];
            default: ;
        endcase

        case ({flip, hc_s[2:0]})
            4'b0011: gfx2_dout <= gfx2_q[ 7: 0];
            4'b0101: gfx2_dout <= gfx2_q[15: 8];
            4'b0111: gfx2_dout <= gfx2_q[23:16];
            4'b0001: gfx2_dout <= gfx2_q[31:24];

            4'b1111: gfx2_dout <= gfx2_q[ 7: 0];
            4'b1001: gfx2_dout <= gfx2_q[15: 8];
            4'b1011: gfx2_dout <= gfx2_q[23:16];
            4'b1101: gfx2_dout <= gfx2_q[31:24];

            default: ;
        endcase
    end
end

// z80 bus
wire    [7:0] z80_rom_data;
wire    [7:0] z80_ram_dout;

wire   [15:0] z80_addr;
reg     [7:0] z80_din;
wire    [7:0] z80_dout;

wire z80_wr_n;
wire z80_rd_n;
reg  z80_wait_n;
reg  z80_irq_n;

wire IORQ_n;
wire MREQ_n;
wire M1_n;

//IORQ gets together with M1-pin active/low. 
always @ (posedge clk_sys) begin
    
    if ( reset == 1 ) begin
        z80_irq_n <= 1;
    end else if ( clk_ym == 1 ) begin
        z80_irq_n <= 0;
    end 
    
    // check for interrupt ack and deassert int
    if ( M1_n == 0 && z80_irq_n == 0 && IORQ_n == 0 ) begin
        z80_irq_n <= 1;
    end
end

T80pa u_cpu(
    .RESET_n    ( ~reset ),
    .CLK        ( clk_8M ),
    .CEN_p      ( 1'b1 ),
    .CEN_n      ( 1'b1 ),
    .WAIT_n     ( z80_wait_n ), // don't wait if data is valid or rom access isn't selected
    .INT_n      ( z80_irq_n ),  // opl timer
    .NMI_n      ( 1'b1 ),
    .BUSRQ_n    ( 1'b1 ),
    .RD_n       ( z80_rd_n ),
    .WR_n       ( z80_wr_n ),
    .A          ( z80_addr ),
    .DI         ( z80_din  ),
    .DO         ( z80_dout ),
    // unused
    .DIRSET     ( 1'b0     ),
    .DIR        ( 212'b0   ),
    .OUT0       ( 1'b0     ),
    .RFSH_n     (),
    .IORQ_n     ( IORQ_n ),
    .M1_n       (),
    .BUSAK_n    (),
    .HALT_n     ( 1'b1 ),
    .MREQ_n     ( MREQ_n ),
    .Stop       (),
    .REG        ()
);

reg sound_addr ;
reg  [7:0] sound_data ;

// sound ic write enable
reg sound_wr;

wire [7:0] opl_dout;
wire opl_irq_n;

reg signed [15:0] sample;

assign AUDIO_S = 1'b1 ;

wire opl_sample_clk;

jtopl #(.OPL_TYPE(1)) opl
(
    .rst(reset),
    .clk(clk_4M),
    .cen(1'b1),
    .din(sound_data),
    .addr(sound_addr),
    .cs_n(~( z80_sound0_cs | z80_sound1_cs )),
    .wr_n(~sound_wr),
    .dout(opl_dout),
    .irq_n(opl_irq_n),
    .snd(sample),
    .sample(opl_sample_clk)
);

always @ * begin
    // mix audio
    AUDIO_L <= sample + ($signed({ ~dac1[7], dac1[6:0], 8'b0 }) >>> 1) + ($signed({ ~dac2[7], dac2[6:0], 8'b0 }) >>> 1) ;
    AUDIO_R <= sample + ($signed({ ~dac1[7], dac1[6:0], 8'b0 }) >>> 1) + ($signed({ ~dac2[7], dac2[6:0], 8'b0 }) >>> 1) ;
end

reg [7:0] dac1;
reg [7:0] dac2;


always @ (posedge clk_sys) begin
     if ( clk_4M == 1 ) begin

        z80_wait_n <= 1;
        
        if ( z80_rd_n == 0 ) begin 
            if ( z80_rom_cs ) begin
                z80_din <= z80_rom_data;
            end else if ( z80_ram_cs ) begin
                z80_din <= z80_ram_dout;
            end else if ( z80_latch_clr_cs ) begin
                // todo
                z80_din <= 0;
                      sound_latch <= 8'h0;
                     
            end else if ( z80_latch_r_cs ) begin
                z80_din <= sound_latch;
                // todo
            end else begin
                z80_din <= 8'h00;
            end
        end
        
        sound_wr <= 0 ;
        if ( z80_wr_n == 0 ) begin 
            if ( z80_sound0_cs == 1 || z80_sound1_cs == 1) begin    
                sound_data  <= z80_dout;
                sound_addr <= z80_sound1_cs ; //   opl2 is single bit address
                sound_wr <= 1;
            end else if (z80_dac1_cs == 1 ) begin
                    dac1 <= z80_dout;
                end else if (z80_dac2_cs == 1 ) begin
                    dac2 <= z80_dout;
                end
        end
    end 
     
    if ( clk_16M == 1 ) begin

    if (reset) begin
        flip <= 0;
        scroll_x <= 0;
        scroll_y <= 0;
        prot_state <= 0;
    end else begin
        if (!m68k_rw & !m68k_lds_n & flip_cs) begin
            flip <= m68k_dout[2];
        end
         if (!m68k_rw & scroll_x_cs ) begin
              scroll_x <= m68k_dout[15:0];
         end

         if (!m68k_rw & scroll_y_cs ) begin
              scroll_y <= m68k_dout[15:0];
         end

         if (!m68k_rw & sound_latch_cs ) begin
              sound_latch <= {m68k_dout[6:0],1'b1};
         end

         if (!m68k_rw & prot_chip_cmd_cs ) begin
            prot_cmd <= m68k_dout[7:0] ;
         end

         if (!m68k_rw & prot_chip_data_cs ) begin
            if ( prot_cmd == 8'h33 ) begin
                if ( prot_state == 0 ) begin
                    nb1412m2_addr[15:8] <= m68k_dout[7:0] ; 
                    prot_state <= 8'h11;
                end
            end else if ( prot_cmd == 8'h34 ) begin
                if ( prot_state == 0 ) begin
                    nb1412m2_addr[7:0] <= m68k_dout[7:0] ; 
                    prot_state <= 8'h21;
                end            
            end else if ( prot_cmd == 8'h35 ) begin
                if ( prot_state == 0 ) begin
                    nb1412m2_addr[15:8] <= m68k_dout[7:0] ; 
                    prot_state <= 8'h31;
                end            
            end else if ( prot_cmd == 8'h36 ) begin
                if ( prot_state == 0 ) begin
                    nb1412m2_addr[7:0] <= m68k_dout[7:0] ; 
                    prot_state <= 8'h41;
                end            
            end
         end
    end // clk_16
    
    // writes to nb1412m2 are queued and handled here
    // each write to the nb1412m2 causes a read to the nb1412m2 rom
    // and updates the current decryted value
    if ( prot_state == 8'h11 ) begin   
        // address now vaild, wait for read
        prot_state <= 8'h12;
    end else if ( prot_state == 8'h12 ) begin
        nb1412m2_rom_dout[7:0] = nb1412m2_dout;
        prot_state <= 0;
        
    end else if ( prot_state == 8'h21 ) begin   
        prot_state <= 8'h22;
    end else if ( prot_state == 8'h22 ) begin
        nb1412m2_rom_dout[7:0] = nb1412m2_dout;
        prot_state <= 0;
        
    end else if ( prot_state == 8'h31 ) begin   
        prot_state <= 8'h32;
    end else if ( prot_state == 8'h32 ) begin
        nb1412m2_adj_dout[7:0] = nb1412m2_dout;
        prot_state <= 0;
        
    end else if ( prot_state == 8'h41 ) begin   
        prot_state <= 8'h42;
    end else if ( prot_state == 8'h42 ) begin
        nb1412m2_adj_dout[7:0] = nb1412m2_dout;
        prot_state <= 0;
    end

   if ( reset == 1 ) begin
        z80_wait_n <= 0;
        sound_wr <= 0 ;
          sound_latch <= 8'h00;
   end


end

reg [7:0]  prot_dout;
reg [15:0] prot_rom_addr;
reg [15:0] prot_adj_addr;
reg [7:0]  prot_cmd;
reg [7:0]  prot_state;

reg [15:0] nb1412m2_addr;
wire [7:0] nb1412m2_dout;

reg  [7:0] nb1412m2_adj_dout;
reg  [7:0] nb1412m2_rom_dout;
wire [7:0] nb1412m2_decrypt_dout = nb1412m2_rom_dout - ( 8'h43 - nb1412m2_adj_dout ) ;

//	prot_adj = (0x43 - m_data[m_adj_address]) & 0xff;
//	return m_data[m_rom_address & 0x1fff] - prot_adj;

dual_port_ram #(.LEN(8192)) nb1412m2_adj (
    .clock_a ( clk_sys ),
    .address_a ( nb1412m2_addr ),
    .wren_a ( 1'b0 ),
    .data_a ( ),
    .q_a ( nb1412m2_dout ),
    
    .clock_b ( clk_sys ),
    .address_b ( ioctl_addr[12:0] ),
    .wren_b ( nb1412m2_ioctl_wr ),
    .data_b ( ioctl_dout  ),
    .q_b( )
    );
    
//dual_port_ram #(.LEN(8192)) nb1412m2_rom (
//    .clock_a ( clk_sys ),
//    .address_a ( prot_rom_addr ),
//    .wren_a ( 1'b0 ),
//    .data_a ( ),
//    .q_a ( nb1412m2_rom_dout ),
//    
//    .clock_b ( clk_sys ),
//    .address_b ( ioctl_addr[12:0] ),
//    .wren_b ( nb1412m2_ioctl_wr ),
//    .data_b ( ioctl_dout  ),
//    .q_b( )
//    );    
    

wire [15:0] ram68k_dout;
wire [15:0] prog_rom_data;

// ioctl download addressing    
wire rom_download = ioctl_download && (ioctl_index==0);

wire m68k_rom_h_ioctl_wr = rom_download & ioctl_wr & (ioctl_addr  <  24'h020000) & (ioctl_addr[0] == 1);
wire m68k_rom_l_ioctl_wr = rom_download & ioctl_wr & (ioctl_addr  <  24'h020000) & (ioctl_addr[0] == 0);

wire gfx2_ioctl_wr       = rom_download & ioctl_wr & (ioctl_addr >=  24'h020000) & (ioctl_addr <  24'h040000) ;
wire gfx3_ioctl_wr       = rom_download & ioctl_wr & (ioctl_addr >=  24'h040000) & (ioctl_addr <  24'h060000) ;
wire gfx1_ioctl_wr       = rom_download & ioctl_wr & (ioctl_addr >=  24'h060000) & (ioctl_addr <  24'h064000) ;

wire z80_rom_ioctl_wr    = rom_download & ioctl_wr & (ioctl_addr >=  24'h070000) & (ioctl_addr <  24'h07c000) ;

wire nb1412m2_ioctl_wr   = rom_download & ioctl_wr & (ioctl_addr >=  24'h07c000) & (ioctl_addr <  24'h07e000) ;

wire prom_r_wr           = rom_download & ioctl_wr & (ioctl_addr >=  24'h07E000) & (ioctl_addr <  24'h07E100) ;
wire prom_g_wr           = rom_download & ioctl_wr & (ioctl_addr >=  24'h07E100) & (ioctl_addr <  24'h07E200) ;
wire prom_b_wr           = rom_download & ioctl_wr & (ioctl_addr >=  24'h07E200) & (ioctl_addr <  24'h07E300) ;
wire prom_s_wr           = rom_download & ioctl_wr & (ioctl_addr >=  24'h07E300) & (ioctl_addr <  24'h07E400) ;
wire prom_u_wr           = rom_download & ioctl_wr & (ioctl_addr >=  24'h07E400) & (ioctl_addr <  24'h07E500) ;

reg [3:0] prom_r [255:0] ;
reg [3:0] prom_g [255:0] ;
reg [3:0] prom_b [255:0] ;
reg [3:0] prom_s [255:0] ;
reg [3:0] prom_u [255:0] ;

always @ (posedge clk_sys) begin

    if ( prom_r_wr == 1 ) begin
        prom_r[ioctl_addr[7:0]] <= ioctl_dout[3:0];
    end
     
    if ( prom_g_wr == 1 ) begin
        prom_g[ioctl_addr[7:0]] <= ioctl_dout[3:0];
    end
     
    if ( prom_b_wr == 1 ) begin
        prom_b[ioctl_addr[7:0]] <= ioctl_dout[3:0];
    end
     
    if ( prom_s_wr == 1 ) begin
        prom_s[ioctl_addr[7:0]] <= ioctl_dout[3:0];
    end

    if ( prom_u_wr == 1 ) begin
        prom_u[ioctl_addr[7:0]] <= ioctl_dout[3:0];
    end
     
end

// main 68k ROM low     
// 3.4d & 4.6d
dual_port_ram #(.LEN(65536)) rom64kx8_H (
    .clock_a ( clk_16M ),
    .address_a ( m68k_a[16:1] ),
    .wren_a ( 1'b0 ),
    .data_a ( ),
    .q_a ( prog_rom_data[15:8] ),
    
    .clock_b ( clk_sys ),
    .address_b ( ioctl_addr[16:1] ),
    .wren_b ( m68k_rom_h_ioctl_wr ),
    .data_b ( ioctl_dout  ),
    .q_b( )

    );

// main 68k ROM high 
// // rom 1.4b & 2.6b  
dual_port_ram #(.LEN(65536)) rom64kx8_L (
    .clock_a ( clk_16M ),
    .address_a ( m68k_a[16:1] ),
    .wren_a ( 1'b0 ),
    .data_a ( ),
    .q_a ( prog_rom_data[7:0] ),
    
    .clock_b ( clk_sys ),
    .address_b ( ioctl_addr[16:1] ),
    .wren_b ( m68k_rom_l_ioctl_wr ),
    .data_b ( ioctl_dout  ),
    .q_b( )
    );

// main 68k ram high    
dual_port_ram #(.LEN(4096)) ram4kx8_H (
    .clock_a ( clk_16M ),
    .address_a ( m68k_a[12:1] ),
    .wren_a ( !m68k_rw & m68k_ram_cs & !m68k_uds_n ),
    .data_a ( m68k_dout[15:8]  ),
    .q_a (  ram68k_dout[15:8] ),
    );

// main 68k ram low     
// 0x200 shared with sound cpu            
dual_port_ram #(.LEN(4096)) ram4kx8_L (
    .clock_a ( clk_16M ),
    .address_a ( m68k_a[12:1] ),
    .wren_a ( !m68k_rw & m68k_ram_cs & !m68k_lds_n ),
    .data_a ( m68k_dout[7:0]  ),
    .q_a ( ram68k_dout[7:0] ),
     
     .clock_b ( clk_sys ),
    .address_b ( sprite_shared_addr[7:0] ),  // 64 sprites * 4 bytes for each == 256
    .wren_b ( 1'b0 ),
    .data_b ( ),
    .q_b( sprite_shared_ram_dout )
    );
    
// z80 rom (48k)
dual_port_ram #(.LEN(16'hc000)) rom_z80 (
    .clock_a ( clk_8M ),
    .address_a ( z80_addr[15:0] ),
    .wren_a ( 1'b0 ),
    .data_a (  ),
    .q_a ( z80_rom_data ),
    
    .clock_b ( clk_sys ),
    .address_b ( ioctl_addr[15:0] ),
    .wren_b ( z80_rom_ioctl_wr ),
    .data_b ( ioctl_dout  ),
    .q_b( )
    );
    
// z80 ram    
dual_port_ram #(.LEN(4096)) z80_ram (
    .clock_b ( clk_8M ),  // z80 clock is 4M
    .address_b ( z80_addr[11:0] ),
    .data_b ( z80_dout ),
    .wren_b ( z80_ram_cs & ~z80_wr_n ),
    .q_b ( z80_ram_dout )
    );

    
//  <!-- gfx1   ioctl    0x060000-0x063fff 16K -->
dual_port_ram #(.LEN(16384)) gfx1 (
    .clock_a ( clk_6M ),
    .address_a ( gfx1_addr[13:0] ),
    .wren_a ( 1'b0 ),
    .data_a ( ),
    .q_a ( gfx1_dout[7:0] ),
    
    .clock_b ( clk_sys ),
    .address_b ( ioctl_addr[13:0] ),
    .wren_b ( gfx1_ioctl_wr ),
    .data_b ( ioctl_dout  ),
    .q_b( )
    );
    
//  <!-- gfx2   ioctl    0x020000-0x03FFFF 128K -->
dual_port_ram #(.LEN(131072)) gfx2 (
    .clock_a ( clk_6M ),
    .address_a ( gfx2_addr[16:0] ),
    .wren_a ( 1'b0 ),
    .data_a ( ),
    .q_a ( gfx2_dout[7:0] ),
    
    .clock_b ( clk_sys ),
    .address_b ( ioctl_addr[16:0] ),
    .wren_b ( gfx2_ioctl_wr ),
    .data_b ( ioctl_dout  ),
    .q_b( )
    );

//  <!-- gfx3   ioctl   0x40000-0x5fffff  128K -->     
dual_port_ram #(.LEN(131072)) gfx3 (
    .clock_a ( clk_sys ),
    .address_a ( gfx3_addr[16:0] ),
    .wren_a ( 1'b0 ),
    .data_a ( ),
    .q_a ( gfx3_dout[7:0] ),
    
    .clock_b ( clk_sys ),
    .address_b ( ioctl_addr[16:0] ),
    .wren_b ( gfx3_ioctl_wr ),
    .data_b ( ioctl_dout  ),
    .q_b( )
    );

reg   [9:0] fg_ram_addr;
wire [15:0] fg_ram_dout;

// 2 x 1k
dual_port_ram #(.LEN(2048)) fg_ram_l (
    .clock_a ( clk_16M ),
    .address_a ( m68k_a[11:1] ),
    .wren_a ( !m68k_rw & fg_ram_cs & !m68k_lds_n ),
    .data_a ( m68k_dout[7:0]  ),
    .q_a (  ),

    .clock_b ( clk_sys ),
    .address_b ( fg_ram_addr  ),
    .wren_b ( 1'b0 ),
    .data_b (  ),
    .q_b( fg_ram_dout[7:0]  )

    );

dual_port_ram #(.LEN(2048)) fg_ram_h (
    .clock_a ( clk_16M ),
    .address_a ( m68k_a[11:1] ),
    .wren_a ( !m68k_rw & fg_ram_cs & !m68k_lds_n ),
    .data_a ( m68k_dout[15:8]  ),
    .q_a (  ),
    
    .clock_b ( clk_sys ),
    .address_b ( fg_ram_addr  ),
    .wren_b ( 1'b0 ),
    .data_b (  ),
    .q_b( fg_ram_dout[15:8]  )
    );
    
    
reg  [11:0] bg_ram_addr;
wire [15:0] bg_ram_dout;

dual_port_ram #(.LEN(2048)) bg_ram_l (
    .clock_a ( clk_8M ),
    .address_a ( m68k_a[11:1] ),
    .wren_a ( !m68k_rw & bg_ram_cs & !m68k_lds_n ),
    .data_a ( m68k_dout[7:0]  ),
    .q_a (  ),

    .clock_b ( clk_sys ),
    .address_b ( bg_ram_addr  ),
    .wren_b ( 1'b0 ),
    .data_b (  ),
    .q_b( bg_ram_dout[7:0]  )

    );

dual_port_ram #(.LEN(2048)) bg_ram_h (
    .clock_a ( clk_8M ),
    .address_a ( m68k_a[11:1] ),
    .wren_a ( !m68k_rw & bg_ram_cs & !m68k_lds_n ),
    .data_a ( m68k_dout[15:8]  ),
    .q_a (  ),
    
    .clock_b ( clk_sys ), 
    .address_b ( bg_ram_addr  ),
    .wren_b ( 1'b0 ),
    .data_b (  ),
    .q_b( bg_ram_dout[15:8]  )
    );    

reg  [11:0] m68k_ram1_addr;
wire [15:0] m68k_ram1_dout;

dual_port_ram #(.LEN(2048)) m68k_ram1_l (
    .clock_a ( clk_16M ),
    .address_a ( m68k_a[11:1] ),
    .wren_a ( !m68k_rw & m68k_ram1_cs & !m68k_lds_n ),
    .data_a ( m68k_dout[7:0]  ),
    .q_a ( m68k_ram1_dout[7:0] )
    );

dual_port_ram #(.LEN(2048)) m68k_ram1_h (
    .clock_a ( clk_16M ),
    .address_a ( m68k_a[11:1] ),
    .wren_a ( !m68k_rw & m68k_ram1_cs & !m68k_lds_n ),
    .data_a ( m68k_dout[15:8]  ),
    .q_a ( m68k_ram1_dout[15:8] )
    );
    
    
endmodule


module delay
(
    input clk,  
    input i,
    output o
);

reg [3:0] r;

assign o = r[3]; 

always @(posedge clk) begin
    r <= { r[2:0], i };
end

endmodule
