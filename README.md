
# Nichibutsu M68000 (Terra Cresta) FPGA Implementation

FPGA compatible core of Nichibutsu M68000 (Terra Cresta Based) arcade hardware for [**MiSTerFPGA**](https://github.com/MiSTer-devel/Main_MiSTer/wiki) written by [**Darren Olafson**](https://twitter.com/Darren__O).  Terra Cresta YM2203 OPN Type PCB donated by [**@atrac17**](https://twitter.com/_atrac17) / [**@djhardrich**](https://twitter.com/djhardrich). 

Currently in an beta state, this core is in active development with assistance from [**atrac17**](https://github.com/atrac17).

![Logo](https://user-images.githubusercontent.com/32810066/160257413-889da2d8-f968-4bd1-9adc-fb22552f0455.png)

## Supported Games

| Title | Status | Released |
|------|---------|----------|
[**Terra Cresta**](https://en.wikipedia.org/wiki/Terra_Cresta)                | **Beta** | Y |
[**Sei Senshi Amatelass**](https://en.wikipedia.org/wiki/Nihon_Bussan)        | Pending  | N |
[**Kid no Hore Hore Daisakusen**](https://en.wikipedia.org/wiki/Nihon_Bussan) | **Beta** | Y |

## External Modules

|Name| Purpose | Author |
|----|---------|--------|
| [**fx68k**](https://github.com/ijor/fx68k)    | [**Motorola 68000 CPU**](https://en.wikipedia.org/wiki/Motorola_68000) | Jorge Cwik     |
| [**t80**](https://opencores.org/projects/t80) | [**Zilog Z80 CPU**](https://en.wikipedia.org/wiki/Zilog_Z80)           | Daniel Wallner |
| [**jtopl**](https://github.com/jotego/jtopl)  | [**Yamaha OPL**](https://en.wikipedia.org/wiki/Yamaha_OPL#OPL)         | Jose Tejada    |

# Known Issues / Tasks

- ~~Clock domains need to be verified~~  
- ~~H/V clock timing for CRT need to be verified~~  
- ~~Palette issue (wrong colors, stray green/tan lines)~~  
- ~~Sprite flip on boss (right arm)~~  
- ~~Dot Crawl on Y/C video output~~  
- ~~Map Test / Service to keyboard handler~~  
- ~~Service Menu (push button service menu) in Kid no Hore Hore Daisakusen~~  
- Additional debugging features (layer toggle)  
- Sprite / Tile offsets in Kid no Hore Hore Daisakusen (screen transitions)  
- Screen Flip implementation  
- Reverse engineer Terra Cresta and provide schematics  
- Protection IC **nb1412m2** implementation  

# PCB Check List / FPGA Features

FPGA implementation is based on Terra Cresta and will be verified against the YM2203 PSG Type PCB with a YM3526 swap. 

The intent is for this core to be a 1:1 implementation of the Nichibutsu (Terra Cresta based) 68000 hardware.

Reverse engineering of an authentic Terra Cresta PCB will be done by [**Darren Olafson**](https://twitter.com/Darren__O) and schematics will be included in the repository.

### Clock Information

H-Sync      | V-Sync      | Source |
------------|-------------|--------|
15.625kHz   | 59.323592Hz | [RT5x](https://github.com/va7deo/TerraCresta/blob/main/doc/Logic%20Analyzer/tc_rt5x.jpg)/[DSLogic +](https://github.com/va7deo/TerraCresta/blob/main/doc/Logic%20Analyzer/tc_csync.png) |

### Crystal Oscillators

Location | Freq (MHz) | Use          |
---------|------------|--------------|
2        | 16.000     | M68000       |
X1       | 22.000     | Z80 / YM3526 |

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

### Nichibutsu Custom Components

Location | Chip | Use | PCB | mameset |
---------|------|-----|-----|---------|
15 G (Top Board) | [**Nichibutsu NB1412M42**](https://raw.githubusercontent.com/va7deo/TerraCresta/main/doc/Sei%20Senshi%20Amatelass%20Front.jpg) | Custom Protection IC | Sei Senshi Amatelass / Soldier Girl Amazon (Nichibutsu USA), Kid no Hore Hore Daisakusen | **amazon**, **amatelass**, **horekid**

### FPGA Implemented Features

Currently a W.I.P, more information to follow.

# Control Layout

### 2L6B Control Panel Layout (Common)

- Upright cabinet shares a 1L2B control panel layout (**players are required to switch**).

- Default cabinet style is set to cocktail for Terra Cresta and Sei Senshi Amatelass. This enables multiple controller inputs.

![controls](https://user-images.githubusercontent.com/32810066/165549007-14edc2d0-3afa-4017-93ca-5b9c7dec5f1a.png)

| Cabinet Style | Game | Joystick | Push Button | Start Button | Shared Controls | Dip Default |
|-|-|-|-|-|-|-|
| Cocktail / Upright | Terra Cresta / Sei Senshi Amatelass | 8-way | 2 | 2 | Upright Only | **Cocktail** |
| Cocktail / Upright | Kid no Hore Hore Daisakusen | 4-way | 2 | 2 | No | **Upright** |

### Keyboard Handler

- Keyboard inputs mapped to mame defaults for all functions.

|Services|Coin/Start|
|--|--|
|<table> <tr><th>Functions</th><th>Keymap</th></tr><tr><td>Test</td><td>F2</td></tr><tr><td>Reset</td><td>F3</td></tr><tr><td>Service</td><td>9</td></tr><tr><td>Pause</td><td>P</td></tr> </table> | <table><tr><th>Functions</th><th>Keymap</th><tr><tr><td>P1 Start</td><td>1</td></tr><tr><td>P2 Start</td><td>2</td></tr><tr><td>P1 Coin</td><td>5</td></tr><tr><td>P2 Coin</td><td>6</td></tr> </table>|

|Player 1|Player 2|
|--|--|
|<table> <tr><th>Functions</th><th>Keymap</th></tr><tr><td>P1 Up</td><td>Up</td></tr><tr><td>P1 Down</td><td>Down</td></tr><tr><td>P1 Left</td><td>Left</td></tr><tr><td>P1 Right</td><td>Right</td></tr><tr><td>P1 Bttn 1</td><td>L-CTRL</td></tr><tr><td>P1 Bttn 2</td><td>L-ALT</td></tr> </table> | <table> <tr><th>Functions</th><th>Keymap</th></tr><tr><td>P2 Up</td><td>R</td></tr><tr><td>P2 Down</td><td>F</td></tr><tr><td>P2 Left</td><td>D</td></tr><tr><td>P2 Right</td><td>G</td></tr><tr><td>P2 Bttn 1</td><td>A</td></tr><tr><td>P2 Bttn 2</td><td>S</td></tr> </table>|

# Development Debugging

### Sei Senshi Amatelass

- Toggling dip switch 7 will enable invincibility. When this is enabled, you can overclock the games framerate by holding the 2p Start Button. This feature was used for debugging during development. 

    - In the "Debug" section you will find a toggle for "Turbo". Enabling this removes the requirement to press and hold the 2p Start Button to enable this feature. 

-    This information is not listed in the mame driver and was discovered while adding support for Sei Senshi Amatelass.


### Kid no Hore Hore Daisakusen

- The following dip switches are set to default "Debug Mode" and cabinet "Upright". This will unlock the following debug features used for debugging during development.

    - For level selection, insert a coin and press player 2 button 1 and 2. In the bottom right corner, 00 will be displayed. Pressing player 2 button 1 and 2 and player 1 button 1 increases the level. Pressing player 2 button 1 and 2 and player 1 button 2  decreases the level. Press player 1 start after choosing your level selection. 

    - Invincibility and infinite time are set by inserting a coin and pressing player 2 button 1 and 2 and player 1 start buttons. If you wish to do this and enable the debug level select, set your level prior to enabling these debug features.

-    This information is taken from the mame driver. To access these features easily, use the keyboard handler. Mapping information is above.

# Support

Please consider showing support for this and future projects via [**Ko-fi**](https://ko-fi.com/darreno). While it isn't necessary, it's greatly appreciated.

# Licensing

Contact the author for special licensing needs. Otherwise follow the GPLv2 license attached.
