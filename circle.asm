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
    LD H, 0          ; x = 0
    LD L, B          ; y = r
    LD C, 3          ; P = 3 - 2*r
    LD A, B
    ADD A, A
    NEG
    ADD A, C
    LD C, A

.loop:
    CALL .draw_octants

    ; Exit if x > y
    LD A, H
    CP L
    RET NC

    ; Update decision parameter
    LD A, C
    BIT 7, A
    JR NZ, .p_neg

    ; Case when P >= 0
    DEC L            ; y--
    LD A, C
    ADD A, H
    ADD A, H
    ADD A, H
    ADD A, H         ; 4*x
    SUB L
    SUB L
    SUB L
    SUB L            ; -4*y
    ADD A, 10        ; P += 4*(x-y) + 10
    LD C, A
    JR .p_update

.p_neg:             ; Case when P < 0
    LD A, C
    ADD A, H
    ADD A, H
    ADD A, H
    ADD A, H         ; 4*x
    ADD A, 6         ; P += 4*x + 6
    LD C, A

.p_update:
    INC H            ; x++
    JP .loop

.draw_octants:
    PUSH HL
    PUSH DE

    ; 8 symmetric points
    LD A, D : ADD H : LD B, A : LD A, E : ADD L : CALL PlotPixel ; (x+h,y+l)
    LD A, D : SUB H : LD B, A : LD A, E : ADD L : CALL PlotPixel ; (x-h,y+l)
    LD A, D : ADD H : LD B, A : LD A, E : SUB L : CALL PlotPixel ; (x+h,y-l)
    LD A, D : SUB H : LD B, A : LD A, E : SUB L : CALL PlotPixel ; (x-h,y-l)
    LD A, D : ADD L : LD B, A : LD A, E : ADD H : CALL PlotPixel ; (x+l,y+h)
    LD A, D : SUB L : LD B, A : LD A, E : ADD H : CALL PlotPixel ; (x-l,y+h)
    LD A, D : ADD L : LD B, A : LD A, E : SUB H : CALL PlotPixel ; (x+l,y-h)
    LD A, D : SUB L : LD B, A : LD A, E : SUB H : CALL PlotPixel ; (x-l,y-h)

    POP DE
    POP HL
    RET

; ========================
; Draw pixel (improved)
; B = X (0-255), A = Y (0-191)
; ========================
PlotPixel:
    CP 192
    RET NC

    PUSH BC
    PUSH DE
    PUSH HL

    ; Calculate Y address
    LD H, 0
    LD L, A
    ADD HL, HL
    LD DE, SCREEN_Y_LOOKUP
    ADD HL, DE
    LD E, (HL)
    INC HL
    LD D, (HL)

    ; Calculate X address
    LD A, B
    SRL A
    SRL A
    SRL A
    ADD A, E
    LD E, A

    ; Bit position corrected (rotate right)
    LD A, B
    AND 7
    LD B, A
    LD A, 0x80
.bit_loop:
    RRCA             ; Rotate right
    DJNZ .bit_loop

    ; Set pixel
    LD C, A
    LD A, (DE)
    OR C
    LD (DE), A

    POP HL
    POP DE
    POP BC
    RET

; Full screen address table
SCREEN_Y_LOOKUP:
    DW $4000,$4100,$4200,$4300,$4400,$4500,$4600,$4700
    DW $4020,$4120,$4220,$4320,$4420,$4520,$4620,$4720
    DW $4040,$4140,$4240,$4340,$4440,$4540,$4640,$4740
    DW $4060,$4160,$4260,$4360,$4460,$4560,$4660,$4760
    DW $4080,$4180,$4280,$4380,$4480,$4580,$4680,$4780
    DW $40A0,$41A0,$42A0,$43A0,$44A0,$45A0,$46A0,$47A0
    DW $40C0,$41C0,$42C0,$43C0,$44C0,$45C0,$46C0,$47C0
    DW $40E0,$41E0,$42E0,$43E0,$44E0,$45E0,$46E0,$47E0
    DW $4800,$4900,$4A00,$4B00,$4C00,$4D00,$4E00,$4F00
    DW $4820,$4920,$4A20,$4B20,$4C20,$4D20,$4E20,$4F20
    DW $4840,$4940,$4A40,$4B40,$4C40,$4D40,$4E40,$4F40
    DW $4860,$4960,$4A60,$4B60,$4C60,$4D60,$4E60,$4F60
    DW $4880,$4980,$4A80,$4B80,$4C80,$4D80,$4E80,$4F80
    DW $48A0,$49A0,$4AA0,$4BA0,$4CA0,$4DA0,$4EA0,$4FA0
    DW $48C0,$49C0,$4AC0,$4BC0,$4CC0,$4DC0,$4EC0,$4FC0
    DW $48E0,$49E0,$4AE0,$4BE0,$4CE0,$4DE0,$4EE0,$4FE0
    DW $5000,$5100,$5200,$5300,$5400,$5500,$5600,$5700
    DW $5020,$5120,$5220,$5320,$5420,$5520,$5620,$5720
    DW $5040,$5140,$5240,$5340,$5440,$5540,$5640,$5740
    DW $5060,$5160,$5260,$5360,$5460,$5560,$5660,$5760
    DW $5080,$5180,$5280,$5380,$5480,$5580,$5680,$5780
    DW $50A0,$51A0,$52A0,$53A0,$54A0,$55A0,$56A0,$57A0
    DW $50C0,$51C0,$52C0,$53C0,$54C0,$55C0,$56C0,$57C0
    DW $50E0,$51E0,$52E0,$53E0,$54E0,$55E0,$56E0,$57E0

CLEAR_SCREEN:
    LD HL, $4000
    LD DE, $4001
    LD BC, $17FF
    LD (HL), 0
    LDIR
    RET

    SAVESNA "circle.sna", Start