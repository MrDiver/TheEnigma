from dataclasses import dataclass

#
# 16-bit word layout (little-endian in memory)
# ─────────────────────────────────────────────
#  bit  15  14  13  12  11  10   9   8   7   6   5   4   3   2   1   0
#      ─── ─── ─── ─── ─── ─── ─── ─── ─── ─── ─── ─── ─── ─── ─── ───
#      [X] [    chr3 (5)     ] [     chr2 (5)    ] [    chr1 (5)     ]
# 
# access:
#   chr1 →  and 0x1f
#   chr2 →  shr 5  + and 0x1f
#   chr3 →  shr 10 + and 0x1f
# 
# wildcard = 0b11111 = 0x1f = 31  (padding / sentinel)
#
# positions array (e.g. ROTOR1, 26 entries + 1 wildcard padding = 27 = 9 words)
# ──────────────────────────────────────────────────────────────────────────────
# word 0           word 1           word 2           word 3
# [p2][p1][p0]     [p5][p4][p3]     [p8][p7][p6]     [p11][p10][p9]
# 
# word 4           word 5           word 6           word 7           word 8
# [p14][p13][p12]  [p17][p16][p15]  [p20][p19][p18]  [p23][p22][p21]  [WLD][p25][p24]
#                                                                       |
#                                                                       wildcard (0x1f)
# ──────────────────────────────────────────────────────────────────────────────
# p0..p25 = A..Z,  WLD = 0x1f

WILDCARD = 0b11111

def to_pos(c: str) -> int:
    return ord(c.upper()) - ord('A')

def forward(rotor: str) -> list[int]:
    return [to_pos(c) for c in rotor]

def reverse(positions: list[int]) -> list[int]:
    result = [0] * len(positions)
    for i, pos in enumerate(positions):
        if pos < 26:
            result[pos] = i
    return result

def reflector(mapping: str) -> list[int]:
    positions = [0] * 26
    for i, c1 in enumerate(mapping):
        for j, c2 in enumerate(mapping[i+1:]):
            if c1 == c2:
                idx = i + 1 + j
                positions[i] = idx
                positions[idx] = i
    return positions

def to_nasm_rotor(name: str, positions: list[int], notch: int, rotation: int = 0) -> str:
    lines = [f'{name}:']
    lines.append(f'db 0x{rotation:02x}')
    lines.append(f'db 0x{notch:02x}')
    for w in positions:
        lines.append(f'db 0x{w:02x}')
    # for w in encode(reverse(positions)):
    #     lines.append(f'dw 0x{w:04x}')
    return '\n'.join(lines)

def to_nasm(name: str, positions: list[int]) -> str:
    return f'{name}:\n' + '\n'.join(f'db 0x{w:02x}' for w in positions)

if __name__ == '__main__':
    rot1 = forward('EKMFLGDQVZNTOWYHXUSPAIBRCJ')
    rot2 = forward('AJDKSIRUXBLHWTMCQGZNPYFVOE')
    rot3 = forward('BDFHJLCPRTXVZNYEIWGAKMUSQO')
    notches = forward('QEV')
    rotations = forward('MCK')

    output = '\n'.join([
        to_nasm_rotor('ROTOR1', rot1, notches[0], rotations[0]),
        to_nasm_rotor('ROTOR2', rot2, notches[1], rotations[1]),
        to_nasm_rotor('ROTOR3', rot3, notches[2], rotations[2]),
        to_nasm('REFLECTOR', reflector('ABCDEFGDIJKGMKMIEBFTCVVJAT')),
    ])

    with open('rotors_gen.nasm', 'w') as f:
        f.write(output)
