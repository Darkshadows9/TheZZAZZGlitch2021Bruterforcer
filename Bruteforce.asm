main_chunk = D8C8
seed = DAB8
seed_scramble[4] = DABC
chunk_buffer[4] = D170
Generator X position = DAB4-DAB5
Generator Y position = DAB6-DAB7

wYCoord = D361
wXCoord = D362

Completion password = DAC0-DAC4
DAC0 = Time

item count = DAE4
Inventory = DAE5-DB33

Max HP = DADF
Current HP = DAE0
level = DAE1
EXP until next level = DAE2

00 = right house
0A = flatland
0B = tall grass
0F = tree
32 = trees with interactable
33 = trees with interactable
34 = trees with interactable
60 = trees with interactable
6C = tree pass horizontal
6D = tree pass vertical
6E = tree pass vertical
6F = tree pass horizontal
74 = Partial flower
7A = Full flower

getInitPlayerPos: (A5BE)   ld   hl,main_chunk
  02:A5C1                  ld   bc,NULL
loopA5C4:A5C4              ldi  a,(hl)
  02:A5C5                  cp   a,0A
  02:A5C7                  jr   z,skipA5DF
  02:A5C9                  inc  c
  02:A5CA                  ld   a,c
  02:A5CB                  cp   a,08
  02:A5CD                  jr   nz,loopA5C4
  02:A5CF                  ld   de,0010
  02:A5D2                  add  hl,de
  02:A5D3                  inc  b
  02:A5D4                  ld   c,00
  02:A5D6                  ld   a,b
  02:A5D7                  cp   a,08
  02:A5D9                  jr   nz,loopA5C4
  02:A5DB                  ld   b,b
  02:A5DC                  ld   bc,0404
skipA5DF:A5DF              ld   a,c
  02:A5E0                  add  a
  02:A5E1                  add  a,10
  02:A5E3                  ld   (wXCoord),a
  02:A5E6                  ld   a,b
  02:A5E7                  add  a
  02:A5E8                  add  a,10
  02:A5EA                  ld   (wYCoord),a
  02:A5ED                  ret

; Do operations on seed_scramble[0]-seed_scramble[3] and return a
scrambleDAB: (A847)
  ; seed_scramble[0]++
  02:A847                  ld   a,(seed_scramble[0])
  02:A84A                  inc  a
  02:A84B                  ld   (seed_scramble[0]),a
  ; seed_scramble[1] = (seed_scramble[0] ^ seed_scramble[3]) ^ seed_scramble[1]
  02:A84E                  ld   b,a
  02:A84F                  ld   a,(seed_scramble[3])
  02:A852                  xor  b
  02:A853                  ld   b,a
  02:A854                  ld   a,(seed_scramble[1])
  02:A857                  xor  b
  02:A858                  ld   (seed_scramble[1]),a
  ; seed_scramble[2] += seed_scramble[1]
  02:A85B                  ld   b,a
  02:A85C                  ld   a,(seed_scramble[2])
  02:A85F                  add  b
  02:A860                  ld   (seed_scramble[2]),a
  ; seed_scramble[3] = ((seed_scramble[2] >> 1) ^ seed_scramble[1]) + seed_scramble[3]
  02:A863                  srl  a
  02:A865                  xor  b
  02:A866                  ld   b,a 
  02:A867                  ld   a,(seed_scramble[3])
  02:A86A                  add  b
  02:A86B                  ld   (seed_scramble[3]),a
  02:A86E                  ret

; Load seed[0]-seed[4] into seed_scramble[0]-seed_scramble[3] before scrambling the latter
; de and bc are pass in
; a is returned by the fact that scrambleDAB also returns a
loadAndScrambleDAB: (A86F)
  02:A86F                  ld   hl,seed[0]
  02:A872                  ldi  a,(hl)
  02:A873                  xor  d
  02:A874                  ld   d,a
  02:A875                  ldi  a,(hl)
  02:A876                  xor  e
  02:A877                  ld   e,a
  02:A878                  ldi  a,(hl)
  02:A879                  xor  b
  02:A87A                  ld   b,a
  02:A87B                  ldi  a,(hl)
  02:A87C                  xor  c
  02:A87D                  ld   (hl),d
  02:A87E                  inc  hl
  02:A87F                  ld   (hl),e
  02:A880                  inc  hl
  02:A881                  ld   (hl),b
  02:A882                  inc  hl
  02:A883                  ld   (hl),a
  ; Run the scramble loop 0x10 times
  02:A884                  ld   c,10
scrambleLoop: (A886)       call scrambleDAB
  02:A889                  dec  c
  02:A88A                  jr   nz,scrambleLoop
  02:A88C                  ret

; de and hl passed in
initGenerator: (A88D)      push de ; map x (starts 0001)
  02:A88E                  push hl ; map y (starts 0002)
  ; Place last two bits of e and l in b and c and push it
  02:A88F                  ld   a,e
  02:A890                  and  a,03
  02:A892                  ld   b,a
  02:A893                  ld   a,l
  02:A894                  and  a,03
  02:A896                  ld   c,a
  02:A897                  push bc
  ; bc = hl & 0xFC
  02:A898                  ld   b,h
  02:A899                  ld   a,l
  02:A89A                  and  a,FC
  02:A89C                  ld   c,a
  ; e &= 0xFC
  02:A89D                  ld   a,e
  02:A89E                  and  a,FC
  02:A8A0                  ld   e,a
  ; Function call to get value of de
  02:A8A1                  call loadAndScrambleDAB
  02:A8A4                  call scrambleDAB
  02:A8A7                  and  a,07
  02:A8A9                  ld   d,00
  02:A8AB                  swap a
  02:A8AD                  ld   e,a
  ; Get value of bc
  02:A8AE                  pop  bc
  02:A8AF                  ld   a,c
  02:A8B0                  add  a
  02:A8B1                  add  a
  02:A8B2                  add  b
  02:A8B3                  ld   c,a
  02:A8B4                  ld   b,00
  ; Add those together to get the address
  02:A8B6                  ld   hl,DD0C
  02:A8B9                  add  hl,bc
  02:A8BA                  add  hl,de
  ; Get value from memory and or it with another scramble before loading it
  02:A8BB                  call bankswitchGetMem
  02:A8BE                  ld   c,a
  02:A8BF                  call scrambleDAB
  02:A8C2                  and  a,30
  02:A8C4                  or   c
  02:A8C5                  ld   (ff00+hNPCSpriteOffset),a
  ; If all the or's of all the position bits zero out, load a generic value
  02:A8C7                  pop  hl
  02:A8C8                  pop  de
  02:A8C9                  ld   a,e
  02:A8CA                  or   l
  02:A8CB                  and  a,FC
  02:A8CD                  or   d
  02:A8CE                  or   h
  02:A8CF                  ret  nz
  02:A8D0                  ld   a,c
  02:A8D1                  and  a,0F
  02:A8D3                  ld   (ff00+hNPCSpriteOffset),a
  02:A8D5                  ret

funA8D6: (A8D6)            push bc
  ; Check if a passed in is equal to 0 or 7, and if so loop
loopA8D7: (A8D7)           call scrambleDAB
  02:A8DA                  and  a,07
  02:A8DC                  jr   z,loopA8D7
  02:A8DE                  cp   a,07
  02:A8E0                  jr   z,loopA8D7
  ; Swap nibbles of a and put it into d
  02:A8E2                  swap a
  02:A8E4                  ld   d,a
  ; Check if it's equal to 0 or 7 again
loopA8E5: (A8E5)           call scrambleDAB
  02:A8E8                  and  a,07
  02:A8EA                  jr   z,loopA8E5
  02:A8EC                  cp   a,07
  02:A8EE                  jr   z,loopA8E5
  ; or both d's together, combining the nibbles together with the last loop set being the high nibble
  02:A8F0                  or   d
  02:A8F1                  ld   d,a
  ; pop value passed into function, mixing it with the created d in both positions, then push them to save
  02:A8F2                  pop  hl
  02:A8F3                  ld   b,d
  02:A8F4                  ld   c,l
  02:A8F5                  push bc
  02:A8F6                  ld   b,h
  02:A8F7                  ld   c,d
  02:A8F8                  push de
  ; call before we just naturally go to it anyway
  02:A8F9                  call skipA8FE
  ; Retrieve the values created before the call
  02:A8FC                  pop  de
  02:A8FD                  pop  bc
skipA8FE:
  ; Load e into (ff00+hFindPathNumSteps), which is the scrambled d
  02:A8FE                  ld   a,e
  02:A8FF                  ld   (ff00+hFindPathNumSteps),a
  ; Take the high nibble of the scrambled d as the low nibble and load it into d
  02:A901                  ld   a,b
  02:A902                  swap a
  02:A904                  and  a,0F
  02:A906                  ld   d,a
  ; Take the high nibble of the low byte of the passed in value and compare it with d
  02:A907                  ld   a,c
  02:A908                  swap a
  02:A90A                  and  a,0F
  02:A90C                  cp   d
  ; if(a < d) d = 0xF0, else d = 0x10
  02:A90D                  ld   d,F0
  02:A90F                  jr   c,skipA913
  02:A911                  ld   d,10
  ; Take the low nibble of scrambled d and put it in e
skipA913: (A913)           ld   a,b
  02:A914                  and  a,0F
  02:A916                  ld   e,a
  ; Take the low nibble of the low byte of the passed in value and compare it with e
  02:A917                  ld   a,c
  02:A918                  and  a,0F
  02:A91A                  cp   e
  ; if(a < e) e = 0xFF, else e = 0x01
  02:A91B                  ld   e,FF
  02:A91D                  jr   c,loopA921
  02:A91F                  ld   e,01
loopA921: (A921)           call writeOffsetChunk
  02:A924                  ld   a,b
  02:A925                  swap a
  02:A927                  and  a,0F
  02:A929                  ld   h,a
  02:A92A                  ld   a,c
  02:A92B                  swap a
  02:A92D                  and  a,0F
  02:A92F                  cp   h
  02:A930                  jr   z,skipA935
  02:A932                  ld   a,b
  02:A933                  add  d
  02:A934                  ld   b,a
skipA935: (A935)           call writeOffsetChunk
  02:A938                  ld   a,b
  02:A939                  and  a,0F
  02:A93B                  ld   h,a
  02:A93C                  ld   a,c
  02:A93D                  and  a,0F
  02:A93F                  cp   h
  02:A940                  jr   z,skipA945
  02:A942                  ld   a,b
  02:A943                  add  e
  02:A944                  ld   b,a
skipA945: (A945)           call writeOffsetChunk
  02:A948                  ld   a,b
  02:A949                  cp   c
  02:A94A                  jr   nz,loopA921
  02:A94C                  ret

; Modify offset of chunk_buffer based on value of nibbles in b
writeOffsetChunk: (A94D)   ld   hl,chunk_buffer
  02:A950                  ld   a,b
  02:A951                  and  a,0F ; take low nibble passed in by b
  02:A953                  add  a
  02:A954                  add  a
  02:A955                  add  a ; multiply by 8
  02:A956                  add  l
  02:A957                  ld   l,a ; add it to buffer's address
  02:A958                  ld   a,b ; reload original b value
  02:A959                  swap a
  02:A95B                  and  a,0F ; take high nibble as low nibble
  02:A95D                  add  l
  02:A95E                  ld   l,a ; add it to buffer's address
  02:A95F                  ld   a,(ff00+hFindPathNumSteps)
  02:A961                  ld   (hl),a
  02:A962                  ret

callWrapperA8D6: (A963)    push bc
  02:A964                  push de
  02:A965                  call funA8D6
  02:A968                  pop  de
  02:A969                  pop  bc
  02:A96A                  ret

funA96B: (A96B)            ld   a,F8
  02:A96D                  add  l
  02:A96E                  ld   l,a
  02:A96F                  ld   a,(ff00+hFindPathNumSteps)
  02:A971                  ld   (hl),a
  02:A972                  ld   a,08
  02:A974                  add  l
  02:A975                  ld   l,a
  02:A976                  ret  

funA977: (A977)            ld   a,08
  02:A979                  add  l
  02:A97A                  ld   l,a
  02:A97B                  ld   a,(ff00+hFindPathNumSteps)
  02:A97D                  ld   (hl),a
  02:A97E                  ld   a,F8
  02:A980                  add  l
  02:A981                  ld   l,a
  02:A982                  ret

funA983: (A983)            dec  l
  02:A984                  ld   a,(ff00+hFindPathNumSteps)
  02:A986                  ld   (hl),a
  02:A987                  inc  l
  02:A988                  ret

funA989: (A989)            inc  l
  02:A98A                  ld   a,(ff00+hFindPathNumSteps)
  02:A98C                  ld   (hl),a
  02:A98D                  dec  l
  02:A98E                  ret

funA98F: (A98F)            ld   hl,chunk_buffer[8]
  02:A992                  ld   de,D1B8
  02:A995                  ld   c,30
loopA997: (A997)           ldi  a,(hl)
  02:A998                  ld   (de),a
  02:A999                  inc  e
  02:A99A                  dec  c
  02:A99B                  jr   nz,loopA997
  02:A99D                  ld   hl,chunk_buffer[8]
  02:A9A0                  ld   de,D1B8
  02:A9A3                  ld   c,30
loopA9A5: (A9A5)           ld   a,(de)
  02:A9A6                  ld   b,a
  02:A9A7                  ld   a,(ff00+hFindPathNumSteps)
  02:A9A9                  cp   b
  02:A9AA                  jr   nz,skipA9CD
  02:A9AC                  ld   a,l
  02:A9AD                  and  a,07
  02:A9AF                  jr   z,skipA9CD
  02:A9B1                  cp   a,07
  02:A9B3                  jr   z,skipA9CD
  02:A9B5                  call scrambleDAB
  02:A9B8                  ld   b,a
  02:A9B9                  bit  0,b
  02:A9BB                  call nz,funA983
  02:A9BE                  bit  1,b
  02:A9C0                  call nz,funA989
  02:A9C3                  bit  2,b
  02:A9C5                  call nz,funA96B
  02:A9C8                  bit  3,b
  02:A9CA                  call nz,funA977
skipA9CD: (A9CD)           inc  e
  02:A9CE                  inc  l
  02:A9CF                  dec  c
  02:A9D0                  jr   nz,loopA9A5
  02:A9D2                  ret

funA9D3: (A9D3)            ld   a,b
  02:A9D4                  ld   (ff00+hFindPathNumSteps),a
  02:A9D6                  ld   hl,chunk_buffer
  02:A9D9                  ld   e,40
loopA9DB:A9DB              ldi  a,(hl)
  02:A9DC                  cp   b
  02:A9DD                  jr   nz,skipA9EB
  02:A9DF                  call scrambleDAB
  02:A9E2                  cp   d
  02:A9E3                  ld   a,(ff00+hFindPathNumSteps)
  02:A9E5                  ld   b,a
  02:A9E6                  jr   nc,skipA9EB
  02:A9E8                  ld   a,c
  02:A9E9                  dec  hl
  02:A9EA                  ldi  (hl),a
skipA9EB: (A9EB)           dec  e
  02:A9EC                  jr   nz,loopA9DB
  02:A9EE                  ret

funA9EF: (A9EF)            ld   a,b
  02:A9F0                  ld   (ff00+hFindPathNumSteps),a
  02:A9F2                  ld   hl,chunk_buffer[8]
  02:A9F5                  ld   e,30
loopA9F7: (A9F7)           ld   a,l
  02:A9F8                  and  a,07
  02:A9FA                  jr   z,skipAA0F
  02:A9FC                  cp   a,07
  02:A9FE                  jr   z,skipAA0F
  02:AA00                  ld   a,(hl)
  02:AA01                  cp   b
  02:AA02                  jr   nz,skipAA0F
  02:AA04                  call scrambleDAB
  02:AA07                  cp   d
  02:AA08                  ld   a,(ff00+hFindPathNumSteps)
  02:AA0A                  ld   b,a
  02:AA0B                  jr   nc,skipAA0F
  02:AA0D                  ld   a,c
  02:AA0E                  ld   (hl),a
skipAA0F: (AA0F)           inc  l
  02:AA10                  dec  e
  02:AA11                  jr   nz,loopA9F7
  02:AA13                  ret

funAA14: (AA14)            ld   a,b
  02:AA15                  ld   (ff00+hFindPathNumSteps),a
  02:AA17                  ld   hl,chunk_buffer[8]
  02:AA1A                  ld   e,30
loopAA1C: (AA1C)           ld   a,(hl)
  02:AA1D                  cp   b
  02:AA1E                  jr   nz,skipAA63
  02:AA20                  ld   a,l
  02:AA21                  and  a,07
  02:AA23                  jr   z,skipAA63
  02:AA25                  cp   a,07
  02:AA27                  jr   z,skipAA63
  02:AA29                  call scrambleDAB
  02:AA2C                  cp   d
  02:AA2D                  ld   a,(ff00+hFindPathNumSteps)
  02:AA2F                  ld   b,a
  02:AA30                  jr   c,skipAA63
  02:AA32                  ld   a,l
  02:AA33                  sub  a,08
  02:AA35                  ld   l,a
  02:AA36                  ld   a,(ff00+hFindPathFlags)
  02:AA38                  and  a
  02:AA39                  jr   z,skipAA3E
  02:AA3B                  cp   (hl)
  02:AA3C                  jr   nz,skipAA68
skipAA3E: (AA3E)           ld   a,l
  02:AA3F                  add  a,10
  02:AA41                  ld   l,a
  02:AA42                  ld   a,(ff00+hPowerOf10)
  02:AA44                  and  a
  02:AA45                  jr   z,skipAA4A
  02:AA47                  cp   (hl)
  02:AA48                  jr   nz,skipAA70
skipAA4A: (AA4A)           ld   a,l
  02:AA4B                  sub  a,09
  02:AA4D                  ld   l,a
  02:AA4E                  ld   a,(ff00+hDivideBuffer)
  02:AA50                  and  a
  02:AA51                  jr   z,skipAA56
  02:AA53                  cp   (hl)
  02:AA54                  jr   nz,skipAA78
skipAA56: (AA56)           inc  l
  02:AA57                  inc  l
  02:AA58                  ld   a,(ff00+hNPCPlayerRelativePosPerspective)
  02:AA5A                  and  a
  02:AA5B                  jr   z,skipAA60
  02:AA5D                  cp   (hl)
  02:AA5E                  jr   nz,skipAA7A
skipAA60: (AA60)           dec  l
  02:AA61                  ld   a,c
  02:AA62                  ld   (hl),a
skipAA63: (AA63)           inc  l
  02:AA64                  dec  e
  02:AA65                  jr   nz,loopAA1C
  02:AA67                  ret

skipAA68: (AA68)           ld   a,l
  02:AA69                  add  a,09
  02:AA6B                  ld   l,a
  02:AA6C                  dec  e
  02:AA6D                  jr   nz,loopAA1C
  02:AA6F                  ret
skipAA70: (AA70)           ld   a,l
  02:AA71                  sub  a,07
  02:AA73                  ld   l,a
  02:AA74                  dec  e
  02:AA75                  jr   nz,loopAA1C
  02:AA77                  ret
skipAA78: (AA78)           inc  l
  02:AA79                  inc  l
skipAA7A: (AA7A)           dec  e
  02:AA7B                  jr   nz,loopAA1C
  02:AA7D                  ret

; Generate map chunk in buffer chunk_buffer
generateChunk: (AA7E)      push de ; map x (starts 0001)
  02:AA7F                  push hl ; map y (starts 0002)
  02:AA80                  call initGenerator
  ; Fill 0x40 bytes at chunk_buffer
  02:AA83                  ld   hl,chunk_buffer
  02:AA86                  ld   bc,0040
  02:AA89                  ld   a,0F
  02:AA8B                  call FillMemory
  ; Conditionals
  02:AA8E                  ld   a,(ff00+hNPCSpriteOffset)
  02:AA90                  ld   b,a
  02:AA91                  bit  0,b
  02:AA93                  jr   z,skipAA99
  02:AA95                  ld   a,74
  02:AA97                  ld   (ff00+hMultiplicand),a
skipAA99: (AA99)           bit  1,b
  02:AA9B                  jr   z,skipAAA1
  02:AA9D                  ld   a,04
  02:AA9F                  ld   (ff00+hMultiplicand),a
skipAAA1: (AAA1)           bit  2,b
  02:AAA3                  jr   z,skipAAA9
  02:AAA5                  ld   a,47
  02:AAA7                  ld   (ff00+hMultiplicand),a
skipAAA9: (AAA9)           bit  3,b
  02:AAAB                  jr   z,skipAAB1
  02:AAAD                  ld   a,40
  02:AAAF                  ld   (ff00+hMultiplicand),a
  ;
skipAAB1: (AAB1)           pop  hl
  02:AAB2                  pop  de
  02:AAB3                  push de
  02:AAB4                  push hl
  02:AAB5                  ld   b,h
  02:AAB6                  ld   c,l
  02:AAB7                  call loadAndScrambleDAB
  02:AABA                  ld   a,(ff00+hMultiplicand)
  02:AABC                  ld   b,a
  02:AABD                  ld   a,(ff00+hNPCSpriteOffset)
  02:AABF                  ld   d,a
  02:AAC0                  ld   e,0A
  02:AAC2                  bit  0,d
  02:AAC4                  ld   c,74
  02:AAC6                  call nz,callWrapperA8D6
  02:AAC9                  bit  1,d
  02:AACB                  ld   c,04
  02:AACD                  call nz,callWrapperA8D6
  02:AAD0                  bit  2,d
  02:AAD2                  ld   c,47
  02:AAD4                  call nz,callWrapperA8D6
  02:AAD7                  bit  3,d
  02:AAD9                  ld   c,40
  02:AADB                  call nz,callWrapperA8D6
  02:AADE                  ld   a,0A
  02:AAE0                  ld   (ff00+hFindPathNumSteps),a
  02:AAE2                  push de
  02:AAE3                  call funA98F
  02:AAE6                  pop  de
  02:AAE7                  bit  3,d
  02:AAE9                  ld   b,30
  02:AAEB                  call nz,writeOffsetChunk
  02:AAEE                  ld   b,40
  02:AAF0                  call nz,writeOffsetChunk
  02:AAF3                  bit  2,d
  02:AAF5                  ld   b,37
  02:AAF7                  call nz,writeOffsetChunk
  02:AAFA                  ld   b,47
  02:AAFC                  call nz,writeOffsetChunk
  02:AAFF                  bit  1,d
  02:AB01                  ld   b,03
  02:AB03                  call nz,writeOffsetChunk
  02:AB06                  ld   b,04
  02:AB08                  call nz,writeOffsetChunk
  02:AB0B                  bit  0,d
  02:AB0D                  ld   b,73
  02:AB0F                  call nz,writeOffsetChunk
  02:AB12                  ld   b,74
  02:AB14                  call nz,writeOffsetChunk
  02:AB17                  ld   a,d
  02:AB18                  swap a
  02:AB1A                  and  a,03
  02:AB1C                  add  a
  02:AB1D                  ld   e,a
  02:AB1E                  ld   d,00
  02:AB20                  ld   hl,AB5B
  02:AB23                  add  hl,de
  02:AB24                  ldi  a,(hl)
  02:AB25                  ld   h,(hl)
  02:AB26                  ld   l,a
  02:AB27                  call fun35E3 ; jumps to finishGenerating
  02:AB2A                  ld   hl,chunk_buffer
  02:AB2D                  ld   de,NULL
loopAB30: (AB30)           ldi  a,(hl)
  02:AB31                  cp   a,33
  02:AB33                  call z,funABA6
  02:AB36                  cp   a,32
  02:AB38                  call z,funABA6
  02:AB3B                  cp   a,60
  02:AB3D                  call z,funABA6
  02:AB40                  cp   a,34
  02:AB42                  call z,funABA6
  02:AB45                  cp   a,08
  02:AB47                  call z,funABA6
  02:AB4A                  inc  e
  02:AB4B                  ld   a,e
  02:AB4C                  cp   a,08
  02:AB4E                  jr   nz,loopAB30
  02:AB50                  inc  d
  02:AB51                  ld   e,00
  02:AB53                  ld   a,d
  02:AB54                  cp   a,08
  02:AB56                  jr   nz,loopAB30
  02:AB58                  pop  hl
  02:AB59                  pop  de
  02:AB5A                  ret

funAB63: (AB63)            ld   b,h
  02:AB64                  ld   c,l
  02:AB65                  sla  l
  02:AB67                  rl   h
  02:AB69                  sla  l
  02:AB6B                  rl   h
  02:AB6D                  sla  l
  02:AB6F                  rl   h
  02:AB71                  sla  l
  02:AB73                  rl   h
  02:AB75                  sla  l
  02:AB77                  rl   h
  02:AB79                  add  hl,bc
  02:AB7A                  ld   b,00
  02:AB7C                  ld   c,a
  02:AB7D                  add  hl,bc
  02:AB7E                  ret

funAB7F: (AB7F)            ld   hl,1505
  02:AB82                  ld   a,d
  02:AB83                  call funAB63
  02:AB86                  ld   a,e
  02:AB87                  call funAB63
  02:AB8A                  ld   de,DAB4
  02:AB8D                  ld   a,(de)
  02:AB8E                  call funAB63
  02:AB91                  inc  de
  02:AB92                  ld   a,(de)
  02:AB93                  call funAB63
  02:AB96                  inc  de
  02:AB97                  ld   a,(de)
  02:AB98                  call funAB63
  02:AB9B                  inc  de
  02:AB9C                  ld   a,(de)
  02:AB9D                  call funAB63
  02:ABA0                  ld   a,h
  02:ABA1                  and  a,3F
  02:ABA3                  ld   d,a
  02:ABA4                  ld   e,l
  02:ABA5                  ret

funABA6: (ABA6)            push de
  02:ABA7                  push hl
  02:ABA8                  call funAB7F
  02:ABAB                  ld   b,01
  02:ABAD                  call funDC48
  02:ABB0                  jr   z,skipABC2
  02:ABB2                  pop  hl
  02:ABB3                  dec  hl
  02:ABB4                  ld   de,A220
loopABB7: (ABB7)           ld   a,(de)
  02:ABB8                  inc  de
  02:ABB9                  inc  de
  02:ABBA                  cp   (hl)
  02:ABBB                  jr   nz,loopABB7
  02:ABBD                  dec  de
  02:ABBE                  ld   a,(de)
  02:ABBF                  ldi  (hl),a
  02:ABC0                  pop  de
  02:ABC1                  ret
skipABC2: (ABC2)           pop  hl
  02:ABC3                  pop  de
  02:ABC4                  ret

finishGenerating: (ABC5)   ld   bc,0A0B
  02:ABC8                  ld   d,30
  02:ABCA                  call funA9D3
  02:ABCD                  ld   a,0B
  02:ABCF                  ld   (ff00+hFindPathNumSteps),a
  02:ABD1                  call funA98F
  02:ABD4                  ld   a,0F
  02:ABD6                  ld   (ff00+hFindPathFlags),a
  02:ABD8                  ld   a,0A
  02:ABDA                  ld   (ff00+hPowerOf10),a
  02:ABDC                  xor  a
  02:ABDD                  ld   (ff00+hDivideBuffer),a
  02:ABDF                  ld   (ff00+hNPCPlayerRelativePosPerspective),a
  02:ABE1                  ld   bc,0F6C
  02:ABE4                  ld   d,20
  02:ABE6                  call funAA14
  02:ABE9                  ld   a,0A
  02:ABEB                  ld   (ff00+hFindPathFlags),a
  02:ABED                  ld   a,0F
  02:ABEF                  ld   (ff00+hPowerOf10),a
  02:ABF1                  ld   bc,0F6F
  02:ABF4                  call funAA14
  02:ABF7                  xor  a
  02:ABF8                  ld   (ff00+hFindPathFlags),a
  02:ABFA                  ld   (ff00+hPowerOf10),a
  02:ABFC                  ld   a,0A
  02:ABFE                  ld   (ff00+hDivideBuffer),a
  02:AC00                  ld   a,0F
  02:AC02                  ld   (ff00+hNPCPlayerRelativePosPerspective),a
  02:AC04                  ld   bc,0F6E
  02:AC07                  call funAA14
  02:AC0A                  ld   a,0F
  02:AC0C                  ld   (ff00+hDivideBuffer),a
  02:AC0E                  ld   a,0A
  02:AC10                  ld   (ff00+hNPCPlayerRelativePosPerspective),a
  02:AC12                  ld   bc,0F6D
  02:AC15                  call funAA14
  02:AC18                  ld   bc,0A74
  02:AC1B                  ld   d,30
  02:AC1D                  call funA9D3
  02:AC20                  ld   bc,0A7A
  02:AC23                  ld   d,30
  02:AC25                  call funA9D3
  02:AC28                  ld   bc,6C33
  02:AC2B                  ld   d,40
  02:AC2D                  call funA9EF
  02:AC30                  ld   bc,6D32
  02:AC33                  ld   d,40
  02:AC35                  call funA9EF
  02:AC38                  ld   bc,6E60
  02:AC3B                  ld   d,40
  02:AC3D                  call funA9EF
  02:AC40                  ld   bc,6F34
  02:AC43                  ld   d,40
  02:AC45                  jp   funA9EF

funDB3C: (DB3C)
  ; Save bank being switched to
  01:DB3C                  ld   (DB4C),a
switchbank_a: (DB3F)
  ; Enable SRAM bank A000-BFFF passed in by a, which should be 0x03 or 0x02, sometimes 0x00
  01:DB3F                  ld   (4000),a
  ; Enable RAM and RTC registers
  01:DB42                  ld   a,0A
  01:DB44                  ld   (0000),a
  01:DB47                  ret

bankswitchRet: (DB50)      ld   a,(DB4C)
  01:DB53                  jr   funDB3C

jumpToHL: (DB55)           call bankswitchGetArr
  01:DB58                  jr   bankswitchRet
bankswitchGetArr: (DB5A)   jp   hl ; always seems to be 09FC at this point
  01:DB5B                  call switchbank_a
  01:DB5E                  call CopyData
  01:DB61                  jr   bankswitchRet
bankswitchGetMem: (DB63)   ld   a,03
  01:DB65                  call switchbank_a
  01:DB68                  ld   a,(hl)
  01:DB69                  push af
  01:DB6A                  call bankswitchRet
  01:DB6D                  pop  af
  01:DB6E                  ret

funDC48:DC48               push bc
  01:DC49                  xor  a
  01:DC4A                  call switchbank_a
  01:DC4D                  ld   hl,B700
  01:DC50                  ld   a,e
  01:DC51                  and  a,07
  01:DC53                  ld   c,a
  01:DC54                  srl  d
  01:DC56                  rr   e
  01:DC58                  srl  d
  01:DC5A                  rr   e
  01:DC5C                  srl  d
  01:DC5E                  rr   e
  01:DC60                  ld   b,00
  01:DC62                  inc  c
  01:DC63                  scf
loopDC64: (DC64)           rl   b
  01:DC66                  dec  c
  01:DC67                  jr   nz,loopDC64
  01:DC69                  add  hl,de
  01:DC6A                  pop  de
  01:DC6B                  ld   a,d
  01:DC6C                  and  a
  01:DC6D                  jr   z,skipDC75
  01:DC6F                  ld   a,(hl)
  01:DC70                  and  b
  01:DC71                  ld   b,a
  01:DC72                  jp   bankswitchRet
skipDC75: (DC75)           ld   a,(hl)
  01:DC76                  or   b
  01:DC77                  ld   (hl),a
  01:DC78                  jp   bankswitchRet