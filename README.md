
# Nichibutsu M68000 (Terra Cresta) FPGA Implementation

FPGA compatible core of Nichibutsu M68000 (Terra Cresta Based) arcade hardware for [**MiSTerFPGA**](https://github.com/MiSTer-devel/Main_MiSTer/wiki) written by [**Darren Olafson**](https://twitter.com/Darren__O). 

Currently in an beta state, this core is in active development with assistance from [**atrac17**](https://github.com/atrac17).

![Logo](https://user-images.githubusercontent.com/32810066/160257413-889da2d8-f968-4bd1-9adc-fb22552f0455.png)

## Supported Games

| Title | Status | Released |
|------|---------|----------|
[**Terra Cresta**](https://en.wikipedia.org/wiki/Terra_Cresta) | **Beta** | Y |
[**Sei Senshi Amatelass**](https://en.wikipedia.org/wiki/Nihon_Bussan) | Pending | N |
[**Kid no Hore Hore Daisakusen**](http://adb.arcadeitalia.net/dettaglio_mame.php?game_name=horekid&search_id=) | **Beta** | Y |

## External Modules

|Name| Purpose | Author |
|----|---------|--------|
| [**fx68k**](https://github.com/ijor/fx68k) | [**Motorola 68000 CPU**](https://en.wikipedia.org/wiki/Motorola_68000) | Jorge Cwik |
| [**t80**](https://opencores.org/projects/t80) | [**Zilog Z80 CPU**](https://en.wikipedia.org/wiki/Zilog_Z80) | Daniel Wallner |
| [**jtopl**](https://github.com/jotego/jtopl) | [**Yamaha OPL**](https://en.wikipedia.org/wiki/Yamaha_OPL#OPL) | Jose Tejada |

# Known Issues / Tasks

- ~~Clock domains need to be verified~~  
- ~~H/V clock timing for CRT need to be verified~~  
- ~~Palette issue (wrong colors, stray green/tan lines)~~  
- ~~Sprite flip on boss (right arm)~~  
- Service Menu / Debug Mode dipswitch in Kid no Hore Hore Daisakusen  
- Sprite / Tile offsets in Kid no Hore Hore Daisakusen (Screen Transitions)  
- Screen Flip Implementation  
- Dot Crawl on Y/C video output  
- Reverse engineer Terra Cresta and provide schematics  
- Protection Chip `nb1412m2` implementation  

# PCB Check List

FPGA implementation is based on Terra Cresta and will be verified against the YM2203 PSG Type PCB with a YM3526 swap. 

Currently the FPGA implementation is in beta, reverse engineering of an authentic Terra Cresta PCB will be done by [**Darren Olafson**](https://twitter.com/Darren__O) and schematics will be included in the repository.

**Terra Cresta YM2203 OPN Type PCB** donated by [**@atrac17**](https://twitter.com/_atrac17) / [**@djhardrich**](https://twitter.com/djhardrich).

### Clock Information

H-Sync      | V-Sync      | Source           |
------------|-------------|------------------|
15.625kHz  | 59.323592Hz | [RT5x](https://github.com/va7deo/TerraCresta/blob/main/doc/Logic%20Analyzer/tc_rt5x.jpg)/[DSLogic +](https://github.com/va7deo/TerraCresta/blob/main/doc/Logic%20Analyzer/tc_csync.png)   |

### Crystal Oscillators

Location | Freq (MHz) | Use
---------|------------|-------
2        | 16.000     | M68000
X1       | 22.000     | Z80 / YM3526

**Pixel clock:** 6.00 MHz

**Estimated geometry:**

    383 pixels/line
  
    263 pixels/line

### Main Components

Location | Chip | Use |
---------|------|-----|
I C (Top Board) | [**Motorola 68000 CPU**](https://en.wikipedia.org/wiki/Motorola_68000) | Main CPU |
17 D (Bottom Board) | [**Zilog Z80 CPU**](https://en.wikipedia.org/wiki/Zilog_Z80) | Sound CPU |
20 D (Bottom Board) | [**Yamaha YM3526**](https://en.wikipedia.org/wiki/Yamaha_OPL#OPL) | OPL |

# Support

Please consider showing support for this and future projects via [**Ko-fi**](https://ko-fi.com/darreno). While it isn't necessary, it's greatly appreciated.

# Licensing

Contact the author for special licensing needs. Otherwise follow the GPLv2 license attached.
