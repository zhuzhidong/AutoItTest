CRC_TA = [
    0x0000, 0x1021, 0x2042, 0x3063, 0x4084, 0x50a5, 0x60c6, 0x70e7,
    0x8108, 0x9129, 0xa14a, 0xb16b, 0xc18c, 0xd1ad, 0xe1ce, 0xf1ef
]


def Generate(*CrcBuff):
    da = 0x0
    crc = 0x0
    for buff in CrcBuff:
        code = int(buff, base=16)
        da = crc >> 12
        crc = crc << 4 & 0xffff
        crc ^= CRC_TA[da ^ (code >> 4)]
        da = crc >> 12
        crc = crc << 4 & 0xffff
        crc ^= CRC_TA[da ^ (code & 0x0f)]
    return '{:X}'.format(crc).zfill(4)
    # Fix issue: List variable '@{character}' has no item in index 3.
