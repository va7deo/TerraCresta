
# Nichibutsu M68000 (Terra Cresta) FPGA Implementation

FPGA compatible core of Nichibutsu M68000 (Terra Cresta Based) arcade hardware for [**MiSTerFPGA**](https://github.com/MiSTer-devel/Main_MiSTer/wiki) written by [**Darren Olafson**](https://twitter.com/Darren__O).  Terra Cresta YM2203 OPN Type PCB donated by [**@atrac17**](https://twitter.com/_atrac17) / [**@djhardrich**](https://twitter.com/djhardrich). 


The intent is for this core to be a 1:1 implementation of the Nichibutsu (Terra Cresta based) 68000 hardware. Currently in an beta state, this core is in active development with assistance from [**atrac17**](https://github.com/atrac17).

![Logo](https://user-images.githubusercontent.com/32810066/160257413-889da2d8-f968-4bd1-9adc-fb22552f0455.png)

## Supported Games

| Title | Status | Released |
|------|---------|----------|
[**Terra Cresta**](https://en.wikipedia.org/wiki/Terra_Cresta)                | Implemented | **Y** |
[**Sei Senshi Amatelass**](https://en.wikipedia.org/wiki/Nihon_Bussan)        | W.I.P       | **Y** |
[**Kid no Hore Hore Daisakusen**](https://en.wikipedia.org/wiki/Nihon_Bussan) | W.I.P       | **Y** |

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
- ~~Additional debugging features (layer toggle)~~  
- Sprite / Tile offsets in Kid no Hore Hore Daisakusen (screen transitions)  
- Screen Flip implementation  
- Reverse engineer Terra Cresta and provide schematics  
- Protection IC **NB1412M2** implementation  

# PCB Check List

FPGA implementation is based on Terra Cresta and will be verified against the YM2203 PSG Type PCB with a YM3526 swap. Reverse engineering of an authentic Terra Cresta PCB will be done by [**Darren Olafson**](https://twitter.com/Darren__O); schematics will be included in the repository.

### Clock Information

H-Sync      | V-Sync      | Source |
------------|-------------|--------|
15.625kHz   | 59.323592Hz | [DSLogic +](https://github.com/va7deo/TerraCresta/blob/main/doc/Terra%20Cresta%2006827/tc_csync.png) |

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

| Location | Chip | Use | PCB | ROM set |
|----------|-----|------|-----|---------|
15 G (Top Board) | [**NB1412M42**](https://raw.githubusercontent.com/va7deo/TerraCresta/main/doc/Sei%20Senshi%20Amatelass/Sei%20Senshi%20Amatelass%20Front.jpg) | Protection IC | <u>**Sei Senshi Amatelass / <br>Kid no Hore Hore Daisakusen**</u> | amatelass, amazon, horekid |

# Debugging Features

### GFX Layer Toggle

-  The three graphics layers can be toggled in the OSD under the Debug options or by pressing<br> F7-F9 on the keyboard.

<br>

|Layer Debug|
|:--:|
|<table> <tr> <th>All Layers</th><th>Foreground</th><th>Background</th><th>Sprites</th></tr><tr><td><p align="center"><img width="144" height="192" src="https://user-images.githubusercontent.com/32810066/166094033-c585ac95-f2fc-4505-8c53-28bf46848ff3.png"></p></td><td> <p align="center"><img width="144" height="192" src="https://user-images.githubusercontent.com/32810066/166094056-9a9506c7-65d0-4785-ab2c-df03b28f154d.png"></p></td><td> <p align="center"><img width="144" height="192" src="https://user-images.githubusercontent.com/32810066/166094260-69225a34-8b57-4746-bd8c-22f4f09f3a13.png"></td><td> <p align="center"><img width="144" height="192" src="https://user-images.githubusercontent.com/32810066/166094263-421faaf9-5f14-4ea0-8b82-408e708f7837.png"></td></tr>
 </table>

### Sprite Flip on Axis Toggle

-  To enable sprite flip, in the OSD under the Debug options enable<br> the toggle.

<br>

|Sprite Flip|
|:--:|
|<table> <tr> <th>All Layers</th><th> Sprite Flip X-Axis</th><th>Sprite Flip Y-Axis</th></tr><tr><td><p align="center"><img width="144" height="192" src="https://user-images.githubusercontent.com/32810066/166094328-947de08c-986f-48de-a35a-a6eeb40bbb1c.png"></p></td><td> <p align="center"><img width="144" height="192" src="https://user-images.githubusercontent.com/32810066/166094329-2b916aeb-73c4-46bf-b1f6-4a9f7ca5a829.png"></p></td><td> <p align="center"><img width="144" height="192" src="https://user-images.githubusercontent.com/32810066/166094330-1fd8d1f9-e420-4acb-ad81-f33fcb4bb3d8.png"></td>
 </table>

<h3>Sei Senshi Amatelass</h3>

<br>

> - Toggling dip switch 7 will enable **invincibility**. When this is enabled, you can overclock the games framerate by holding the 2p Start Button. This feature was used for debugging during development.
> 
> - In the **Debug** of the **OSD section** you will find a toggle for **Turbo**. Enabling this removes the requirement to press and hold the 2p Start Button to enable this feature. 

<br>

<h3>Kid no Hore Hore Daisakusen</h3>

<br>

> - The following dip switches are set to default **Debug Mode** and cabinet **Upright**. With these enabled, you will be able to access the following debug features.
> 
> - For **level selection**, insert a coin and press player 2 button 1 and 2. In the bottom right corner, 00 will be displayed. Pressing player 2 button 1 and 2 and player 1 button 1 increases the level. Pressing player 2 button 1 and 2 and player 1 button 2  decreases the level. Press player 1 start after choosing your level selection.
> 
> - **Invincibility** and **infinite time** are set by inserting a coin and pressing player 2 button 1 and 2 and player 1 start buttons. 
>
> - If you wish to enable the debug level select, set your level prior to enabling these debug features.

<br>

# Control Layout

<h3 align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2L6B Control Panel Layout (Common Layout)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</h3>

<p align="left"><img width="730" height="144" src="https://user-images.githubusercontent.com/32810066/165549007-14edc2d0-3afa-4017-93ca-5b9c7dec5f1a.png"></p> 

<h3 align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1L2B Control Panel Layout (Nichibutsu Layout)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</h3>

<p align="left"><img width="730" height="144" src="https://user-images.githubusercontent.com/32810066/167632204-6e6e8ade-189d-46c8-9208-88c3d00b77a3.png"></p>

Game | Joystick | Service Menu | Shared Controls | Dip Default |
--- | :---: | :---: | :---: | :---: |
Terra Cresta| 8-Way | <p align="center"><img width="120" height="160" src="https://user-images.githubusercontent.com/32810066/167633259-f29bc414-06e6-4ea2-aaa0-e31a8b60f4fd.png"></p> | Upright | **Table**
Sei Senshi Amatelass| 8-Way | <p align="center"><img width="120" height="160" src="https://user-images.githubusercontent.com/32810066/167633279-3573d97c-49c0-42b0-8fba-6791ca48d1d7.png"></p> | Upright | **Table**
Kid no Hore Hore Daisakusen| 4-Way | <p align="center"><img width="120" height="160" src="https://user-images.githubusercontent.com/32810066/167633298-22669829-acff-450d-9df0-ca8c0b0600b2.png"></p> | No | **Upright**
<br>

- Upright cabinet shares a 1L2B control panel layout. Players are required to switch controller. The deefault cabinet style is set to table for Terra Cresta and Sei Senshi Amatelass. This enables multiple player controllers.
<br>

### Keyboard Handler

- Keyboard inputs mapped to mame defaults for all functions.

|Services|Coin/Start|
|--|--|
|<table> <tr><th>Functions</th><th>Keymap</th></tr><tr><td>Test</td><td>F2</td></tr><tr><td>Reset</td><td>F3</td></tr><tr><td>Service</td><td>9</td></tr><tr><td>Pause</td><td>P</td></tr> </table> | <table><tr><th>Functions</th><th>Keymap</th><tr><tr><td>P1 Start</td><td>1</td></tr><tr><td>P2 Start</td><td>2</td></tr><tr><td>P1 Coin</td><td>5</td></tr><tr><td>P2 Coin</td><td>6</td></tr> </table>|

|Player 1|Player 2|
|--|--|
|<table> <tr><th>Functions</th><th>Keymap</th></tr><tr><td>P1 Up</td><td>Up</td></tr><tr><td>P1 Down</td><td>Down</td></tr><tr><td>P1 Left</td><td>Left</td></tr><tr><td>P1 Right</td><td>Right</td></tr><tr><td>P1 Bttn 1</td><td>L-CTRL</td></tr><tr><td>P1 Bttn 2</td><td>L-ALT</td></tr> </table> | <table> <tr><th>Functions</th><th>Keymap</th></tr><tr><td>P2 Up</td><td>R</td></tr><tr><td>P2 Down</td><td>F</td></tr><tr><td>P2 Left</td><td>D</td></tr><tr><td>P2 Right</td><td>G</td></tr><tr><td>P2 Bttn 1</td><td>A</td></tr><tr><td>P2 Bttn 2</td><td>S</td></tr> </table>|

|Debug|
|--|
|<table> <tr><th>Functions</th><th>Keymap</th></tr><tr><td>Layer (FG)</td><td>F7</td></tr><tr><td>Layer (BG)</td><td>F8</td></tr><tr><td>Layer (SP)</td><td>F9</td></tr> </table> |

# Support

Please consider showing support for this and future projects via [**Ko-fi**](https://ko-fi.com/darreno). While it isn't necessary, it's greatly appreciated.

# Licensing

Contact the author for special licensing needs. Otherwise follow the GPLv2 license attached.
