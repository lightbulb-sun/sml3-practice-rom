from string import ascii_uppercase, digits

TILE_EMPTY = 0x9a
TILE_LINE = 0xd2
OFFSET_ALPHA = 0x80
OFFSET_DIGITS = 0xa0

LINES = (
#01234567890123456789
'                    '
'    SELECT LEVEL    '
'                    '
'                    '
'                    '
' WORLD   LVL  PWRUP '
' ------------------ '
' RICE         SMALL '
' TEAPOT       NORMAL'
' SHERBET      BULL  '
' STOVE        JET   '
' SS TEA       DRAGON'
' PARSLEY            '
' SYRUP              '
'                    '
'                    '
'     PRESS START    '
'                    '
)

result = bytearray()
for line in LINES:
    for c in line:
        if c in ascii_uppercase:
            cur = ascii_uppercase.index(c) + OFFSET_ALPHA
        elif c in digits:
            cur = digits.index(c) + OFFSET_DIGITS
        elif c == '-':
            cur = TILE_LINE
        else:
            cur = TILE_EMPTY
        result.append(cur)


with open('screen.dat', 'wb') as outf:
    outf.write(result)
