    DEVICE ZXSPECTRUM48
    ORG 32768

Start:
    CALL CLEAR_SCREEN
    LD D, 128        ; Center X (0-255)
    LD E, 96         ; Center Y (0-191)
    LD B, 40         ; Radius (max 96)
    CALL DRAW_CIRCLE
    HALT

; ========================
; Bresenham circle algorithm
; ========================
DRAW_CIRCLE:
    LD IXH, D        ; Store center X in IXH
    LD IXL, E        ; Store center Y in IXL
    LD H, 0          ; x = 0
    LD L, B          ; y = radius
    LD C, 3          ; P = 3 - 2*radius
    LD A, B
    ADD A, A         ; 2*radius
    NEG              ; -2*radius
    ADD A, C         ; 3 - 2*radius
    LD C, A          ; Store initial decision parameter

.loop:
    CALL .draw_octants ; Draw all 8 symmetric points
    LD A, H
    CP L
    RET NC           ; Exit when x >= y

    LD A, C
    BIT 7, A         ; Check P's sign (bit 7)
    JR NZ, .p_neg    ; Jump if P is negative

    ; Case when P >= 0
    DEC L            ; y--
    LD A, H
    ADD A, A
    ADD A, A         ; 4*x
    SUB L
    SUB L
    SUB L
    SUB L            ; -4*y
    ADD A, 10        ; +10
    ADD A, C         ; P += 4*(x-y) + 10
    LD C, A
    JR .p_update

.p_neg:              ; Case when P < 0
    LD A, H
    ADD A, A
    ADD A, A         ; 4*x
    ADD A, 6         ; +6
    ADD A, C         ; P += 4*x + 6
    LD C, A

.p_update:
    INC H            ; x++
    JP .loop

.draw_octants:
    ; First quadrant points (x,y)
    LD A, IXH
    ADD A, H
    LD B, A          ; X + x
    LD A, IXL
    ADD A, L
    CALL PlotPixel   ; Y + y

    LD A, IXH
    SUB H
    LD B, A          ; X - x
    LD A, IXL
    ADD A, L
    CALL PlotPixel   ; Y + y

    LD A, IXH
    ADD A, H
    LD B, A          ; X + x
    LD A, IXL
    SUB L
    CALL PlotPixel   ; Y - y

    LD A, IXH
    SUB H
    LD B, A          ; X - x
    LD A, IXL
    SUB L
    CALL PlotPixel   ; Y - y

    ; Second quadrant points (y,x)
    LD A, IXH
    ADD A, L
    LD B, A          ; X + y
    LD A, IXL
    ADD A, H
    CALL PlotPixel   ; Y + x

    LD A, IXH
    SUB L
    LD B, A          ; X - y
    LD A, IXL
    ADD A, H
    CALL PlotPixel   ; Y + x

    LD A, IXH
    ADD A, L
    LD B, A          ; X + y
    LD A, IXL
    SUB H
    CALL PlotPixel   ; Y - x

    LD A, IXH
    SUB L
    LD B, A          ; X - y
    LD A, IXL
    SUB H
    CALL PlotPixel   ; Y - x
    RET

; ========================
; Optimized pixel plotting
; B = X (0-255), A = Y (0-191)
; ========================
PlotPixel:
    CP 192
    RET NC           ; Return if Y coordinate is invalid (>191)

    PUSH HL
    PUSH DE
    PUSH BC

    ; Calculate screen address from Y coordinate
    LD H, 0
    LD L, A
    ADD HL, HL       ; Multiply Y by 2 (for word lookup)
    LD DE, SCREEN_Y_LOOKUP
    ADD HL, DE       ; HL points to address in lookup table
    LD E, (HL)       ; Get low byte of address
    INC HL
    LD D, (HL)       ; Get high byte of address

    ; Calculate X offset
    LD A, B
    RRA              ; Rotate right 3 times to divide by 8
    RRA
    RRA
    AND 31           ; Mask to 0-31 range
    ADD A, E         ; Add to screen address low byte
    LD E, A

    ; Get bitmask for pixel position
    LD A, B
    AND 7            ; Get pixel position (0-7)
    LD HL, BitTable
    ADD A, L         ; Add offset to table
    LD L, A
    ADC A, H         ; Handle carry if needed
    SUB L
    LD H, A
    LD C, (HL)       ; Get bitmask from table

    ; Set the pixel
    LD A, (DE)       ; Get current screen byte
    OR C             ; OR with our bitmask
    LD (DE), A       ; Write back to screen

    POP BC
    POP DE
    POP HL
    RET

BitTable:
    DB $80, $40, $20, $10, $08, $04, $02, $01  ; Pixel bitmasks

; Screen address lookup table (256 bytes)
SCREEN_Y_LOOKUP:
    DW $4000,$4100,$4200,$4300,$4400,$4500,$4600,$4700,$4020,$4120,$4220,$4320,$4420,$4520,$4620,$4720
    DW $4040,$4140,$4240,$4340,$4440,$4540,$4640,$4740,$4060,$4160,$4260,$4360,$4460,$4560,$4660,$4760
    DW $4080,$4180,$4280,$4380,$4480,$4580,$4680,$4780,$40A0,$41A0,$42A0,$43A0,$44A0,$45A0,$46A0,$47A0
    DW $40C0,$41C0,$42C0,$43C0,$44C0,$45C0,$46C0,$47C0,$40E0,$41E0,$42E0,$43E0,$44E0,$45E0,$46E0,$47E0
    DW $4800,$4900,$4A00,$4B00,$4C00,$4D00,$4E00,$4F00,$4820,$4920,$4A20,$4B20,$4C20,$4D20,$4E20,$4F20
    DW $4840,$4940,$4A40,$4B40,$4C40,$4D40,$4E40,$4F40,$4860,$4960,$4A60,$4B60,$4C60,$4D60,$4E60,$4F60
    DW $4880,$4980,$4A80,$4B80,$4C80,$4D80,$4E80,$4F80,$48A0,$49A0,$4AA0,$4BA0,$4CA0,$4DA0,$4EA0,$4FA0
    DW $48C0,$49C0,$4AC0,$4BC0,$4CC0,$4DC0,$4EC0,$4FC0,$48E0,$49E0,$4AE0,$4BE0,$4CE0,$4DE0,$4EE0,$4FE0
    DW $5000,$5100,$5200,$5300,$5400,$5500,$5600,$5700,$5020,$5120,$5220,$5320,$5420,$5520,$5620,$5720
    DW $5040,$5140,$5240,$5340,$5440,$5540,$5640,$5740,$5060,$5160,$5260,$5360,$5460,$5560,$5660,$5760
    DW $5080,$5180,$5280,$5380,$5480,$5580,$5680,$5780,$50A0,$51A0,$52A0,$53A0,$54A0,$55A0,$56A0,$57A0
    DW $50C0,$51C0,$52C0,$53C0,$54C0,$55C0,$56C0,$57C0,$50E0,$51E0,$52E0,$53E0,$54E0,$55E0,$56E0,$57E0

CLEAR_SCREEN:
    LD HL, $4000     ; Start of screen memory
    LD DE, $4001     ; Next byte
    LD BC, $17FF     ; 6143 bytes to clear (entire screen)
    LD (HL), 0       ; Clear first byte
    LDIR             ; Block copy (clear rest of screen)
    RET

    SAVESNA "circle-optimized.sna", Start