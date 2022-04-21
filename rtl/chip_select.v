//

module chip_select
(
    input  [1:0] pcb,

    input [23:0] cpu_a,
    input        cpu_as_n,

    input [15:0] z80_addr,
    input        MREQ_n,
    input        IORQ_n,
    input        M1_n,

    // M68K selects
    output       prog_rom_cs,
    output       m68k_ram_cs,
    output       bg_ram_cs,
    output       m68k_ram1_cs,
    output       fg_ram_cs,

    output       input_p1_cs,
    output       input_p2_cs,
    output       input_system_cs,
    output       input_dsw_cs,

    output       scroll_x_cs,
    output       scroll_y_cs,

    output       sound_latch_cs,

    // Z80 selects
    output       z80_rom_cs,
    output       z80_ram_cs,

    output       z80_sound0_cs,
    output       z80_sound1_cs,
    output       z80_dac1_cs,
    output       z80_dac2_cs,
    output       z80_latch_clr_cs,
    output       z80_latch_r_cs,

    // other params
    output reg [15:0] scroll_x,
    output reg [15:0] scroll_y,
    output reg [7:0]  sound_latch
);

localparam pcb_terra_cresta     = 0;
localparam pcb_amazon = 1;

function m68k_cs;
        input [23:0] base_address;
        input  [7:0] width;
begin
    m68k_cs = ( cpu_a >> width == base_address >> width ) & !cpu_as_n;
end
endfunction

function z80_mem_cs;
        input [15:0] address_hi;
begin
    z80_mem_cs = ( MREQ_n == 0 && z80_addr[15:0] == address_hi );
end
endfunction

function z80_io_cs;
        input [7:0] address_lo;
begin
    z80_io_cs = ( IORQ_n == 0 && z80_addr[7:0] == address_lo );
end
endfunction

    // Memory mapping based on PCB type
    case (pcb)
        pcb_terra_cresta: begin
            prog_rom_cs       = m68k_cs( 'h000000, 17 );
            m68k_ram_cs       = m68k_cs( 'h020000, 13 );
            bg_ram_cs         = m68k_cs( 'h022000, 12 );
            m68k_ram1_cs      = m68k_cs( 'h023000, 12 );
            fg_ram_cs         = m68k_cs( 'h028000, 11 );

            input_p1_cs       = m68k_cs( 'h024000,  1 );
            input_p2_cs       = m68k_cs( 'h024002,  1 );
            input_system_cs   = m68k_cs( 'h024004,  1 );
            input_dsw_cs      = m68k_cs( 'h024006,  1 );

            scroll_x_cs       = m68k_cs( 'h026002,  1 );
            scroll_y_cs       = m68k_cs( 'h026004,  1 );

            sound_latch_cs    = m68k_cs( 'h02600c,  1 );

            z80_rom_cs         = z80_mem_cs( 16'h000 );
            z80_ram_cs         = z80_mem_cs( 16'h000 );

            z80_sound0_cs      = z80_io_cs(  8'h00 );
            z80_sound1_cs      = z80_io_cs(  8'h01 );
            z80_dac1_cs        = z80_io_cs(  8'h02 );
            z80_dac2_cs        = z80_io_cs(  8'h03 );
            z80_latch_clr_cs   = z80_io_cs(  8'h04 );
            z80_latch_r_cs     = z80_io_cs(  8'h06 );
        end

        pcb_amazon: begin
            prog_rom_cs       = m68k_cs( 'h000000, 17 );
            m68k_ram_cs       = m68k_cs( 'h040000, 13 );
            bg_ram_cs         = m68k_cs( 'h042000, 12 );
            m68k_ram1_cs      = m68k_cs( 'h043000, 12 );
            fg_ram_cs         = m68k_cs( 'h050000, 12 );

            input_p1_cs       = m68k_cs( 'h044000,  1 );
            input_p2_cs       = m68k_cs( 'h044002,  1 );
            input_system_cs   = m68k_cs( 'h044004,  1 );
            input_dsw_cs      = m68k_cs( 'h044006,  1 );

            scroll_x_cs       = m68k_cs( 'h046002,  1 );
            scroll_y_cs       = m68k_cs( 'h046004,  1 );

            sound_latch_cs    = m68k_cs( 'h04600c,  1 );

            z80_rom_cs         = z80_mem_cs( 16'h000 );
            z80_ram_cs         = z80_mem_cs( 16'h000 );

            z80_sound0_cs      = z80_io_cs(  8'h00 );
            z80_sound1_cs      = z80_io_cs(  8'h01 );
            z80_dac1_cs        = z80_io_cs(  8'h02 );
            z80_dac2_cs        = z80_io_cs(  8'h03 );
            z80_latch_clr_cs   = z80_io_cs(  8'h04 );
            z80_latch_r_cs     = z80_io_cs(  8'h06 );
        end

        default:;
    endcase
end

endmodule
