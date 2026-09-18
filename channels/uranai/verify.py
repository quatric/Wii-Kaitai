#!/usr/bin/env python3
"""Parse real dumps with the generated Kaitai parsers and cross-check against small independent decoders below.

  kaitai-struct-compiler -t python --outdir build system/dol.ksy system/u8.ksy channels/uranai/*.ksy
  python3 channels/uranai/verify.py --build build --eu-dol 00000001.app --eu-data 00000006.d \\
      [--kr-dol kr_main.dol] [--jp-dol jp_main.dol]

Every option is optional; checks without their input are skipped. DOLs must be LZ11-decompressed.
"""
import argparse
import os
import struct
import sys

ap = argparse.ArgumentParser()
ap.add_argument("--build", required=True, help="directory with the compiled *.py parsers")
ap.add_argument("--eu-dol")
ap.add_argument("--eu-data", help="unpacked data archive (content 0x06)")
ap.add_argument("--kr-dol")
ap.add_argument("--jp-dol")
a = ap.parse_args()
sys.path.insert(0, a.build)

fails = 0


def check(name, ok, detail=""):
    global fails
    fails += not ok
    print(("PASS " if ok else "FAIL ") + name + (f"  {detail}" if detail else ""))


def dol_slice(path, va, n):
    """Bytes at a virtual address of a DOL (independent of the Kaitai definition)."""
    d = open(path, "rb").read()
    h = struct.unpack(">64I", d[:256])
    for i in range(18):
        off, addr, size = h[i], h[18 + i], h[36 + i]
        if size and addr <= va < addr + size:
            return d[off + va - addr:off + va - addr + n]
    raise ValueError(hex(va))


def ephemeris_fields(blob, i):
    """Nine 9-bit longitudes of record i (three per 32-bit word)."""
    bits = int.from_bytes(blob[i * 16 + 4:i * 16 + 16], "big")
    return [((bits >> (64 - 32 * (k // 3))) & 0xFFFFFFFF) >> (23 - 9 * (k % 3)) & 0x1FF for k in range(9)]


if a.eu_dol:
    from wii_dol import WiiDol
    d = WiiDol.from_file(a.eu_dol)
    check("dol header", d.entry_point == 0x80004050 and d.text_addresses[1] == 0x80024160, hex(d.entry_point))
if a.eu_data:
    from uranai_affinity import UranaiAffinity
    from uranai_ephemeris import UranaiEphemeris
    eph_path = f"{a.eu_data}/logic/wii_ephemeris_decimal_A.bin"
    e = UranaiEphemeris.from_file(eph_path)
    blob = open(eph_path, "rb").read()
    ok = True
    for i in range(0, len(e.days), 997):
        x = e.days[i]
        f = ephemeris_fields(blob, i)
        ok &= f == [x.sun, x.venus, x.moon_midnight, x.saturn, x.mercury, x.jupiter, x.mars, x.moon_noon, x.unused]
    check("ephemeris", ok and len(e.days) == 56978 and e.days[0].year == 1881, f"{len(e.days)} days")
    aff = UranaiAffinity.from_file(f"{a.eu_data}/etc/affinity_eu.bin")
    counts = [(i.rating, i.people, i.count) for i in aff.index]
    check("affinity", len(aff.index) == 15 and all(len(i.variants) == i.count and
                                                     all(len(v.person) == i.people for v in i.variants)
                                                     for i in aff.index), str(counts[:3]))
if a.eu_dol:
    from uranai_score_table_eu import UranaiScoreTableEu
    blob = dol_slice(a.eu_dol, 0x802C6710, 6 * 0x2760)
    s = UranaiScoreTableEu.from_bytes(blob)
    ok = all(s.topics[g].entries[i].score == blob[g * 0x2760 + i * 28 + 2] and
             s.topics[g].entries[i].sign == i // 30 and s.topics[g].entries[i].degree == i % 30 + 1
             for g in range(6) for i in range(360))
    check("score table (EU)", ok)
if a.kr_dol:
    from uranai_colour_table import UranaiColourTable
    c = UranaiColourTable.from_bytes(dol_slice(a.kr_dol, 0x80270C10, 16071 * 12))
    r = c.rows[0]
    cols = list(r.first_half.colour) + list(r.second_half.colour)
    check("colour table (KR)", (r.year, r.month, r.day) == (2007, 1, 1) and len(cols) == 12 and max(cols) <= 22,
          str(cols))
if a.jp_dol:
    from uranai_score_table_jp import UranaiScoreTableJp
    s = UranaiScoreTableJp.from_bytes(dol_slice(a.jp_dol, 0x8036C448, 6 * 0x1C20))
    ok = all(s.topics[g].entries[i].sign == i // 30 and s.topics[g].entries[i].degree == i % 30 + 1
             and 10 <= s.topics[g].entries[i].score <= 20 for g in range(6) for i in range(360))
    check("score table (JP)", ok)

# synthetic save file round trip (no dump needed)
from uranai_save import UranaiSave  # noqa: E402
body = bytearray(0x1C8)
struct.pack_into(">I", body, 4, 2)
for slot, (mid, y, m, dd) in enumerate([(b"\x01" * 8, 1990, 5, 17), (b"\x02" * 8, 1988, 2, 3)]):
    o = 0x48 + slot * 0x40
    body[o:o + 8] = mid
    struct.pack_into(">HBB", body, o + 8, y, m, dd)
    struct.pack_into(">I", body, o + 0x10, 87)
struct.pack_into(">I", body, 0, sum(body[4:]) & 0xFFFFFFFF)
sv = UranaiSave.from_bytes(bytes(body))
check("save round trip", sv.mii_count == 2 and sv.miis[1].birth_year == 1988 and sv.miis[0].score_counters[0] == 87
      and sv.checksum == sum(body[4:]) & 0xFFFFFFFF)
print("done, failures:", fails)
sys.exit(1 if fails else 0)
