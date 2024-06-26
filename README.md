# Mini Colecovision Project
### Schematic, PCB, and CPLD design.

---

  author: Jay Convertino

  date: 2024.03.24

  details: A simple Colecovision that is much smaller than the original, and only uses +5v.

  license: MIT

---

## LICENSE
  - All files related to or generated from the KiCAD source fall under the MIT license.
  - All files related to or generated from the Verilog source fall under the MIT license.
  - All files generated by me, Jay Convertino, fall under the MIT license.
  - All files from other sources fall under the license of their specification.

## RELEASE VERSIONS
### Current
  - 1.0.0 - First working version

### Past
  - DEV

## Wiki
  - Soon(tm)

## Parts list
  - Soon(tm)

## Intro

  This is a miniturization of the original colecovision. All logic is simplified to a single CPLD.

## SOURCES
### Schematic Check
  - Righteous Tentacle Colecovision : https://github.com/sparkletron/righteous_tentacle_colecovision : Jay Convertino

## REQUIREMENTS
  - KiCAD v7.X
  - Quartus v13.0.1sp1 web edition
  - Altera USB Blaster

## BUILD TIPS
  This design is made so anyone can build this. Though it will need a board from a PCB manufacture due to the small pitch and
  vias. There are only a few SMD devices, the CPU, a cap, and a few resistors. These are larger to help make soldering easier.

  Recommend populating the SMD parts first, then moving on to the through hole parts from passive to active. If you do not plan
  on using a battery pack the shotkey diodes can be omitted.

## FILE INFORMATION
  - README.md, is this file.
  - LICENSE.md, is the license file (MIT) for anything create by me, Jay Convertion, that resides in this repository.
  - doc, contains various documents used.
    - datasheets, contains parts used on the board.
  - models, PCB items and case designes (soon)
  - pics, images take by me or others(watermark added) of the colecovision.
    - 3D, images generated by modeling tools.
  - src, Verilog source for CPLD
    - protable_coleco, contains verilog source, test bench and fusesoc core file.
    - quartus13sp01, contains quartus project for MAX7000 series CPLD
      - bin, contains CPLD firmware for varous compatible chips.
  - schematic, contains KiCAD schematic files.
    - coleco_original.kicad_pro, this file is the main project file that contains EVERTHING.
    - gerber, containts all exports from KiCAD
    - lib, external components for KiCAD
      - CONNECTOR_PCBEdge_EXT
      - LOGOS
      - MHPS2273
      - MODELS
      - MOUNTS
      - OS102011MA1QN1
      - PADS
      - POWER_SYMBOLS
      - RCJ-041
      - RF_MODULATORS
      - SWITCHES_THT
      - TE_550841-2
      - VARIABLE_INDUCTORS
      - VINTAGE_AUDIO_SYNTH
      - VINTAGE_RAM
      - VINTAGE_VDP
    - PDF, various KiCAD exports in the PDF format. PCB and/or schematics.

## PCB IMAGE

![pcb_3D_img_front|300](pics/3D/coleco_original_front.jpg)

![pcb_3D_img_back|300](pics/3D/coleco_original_back.jpg)
