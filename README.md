# Wii-Kaitai

[Kaitai Struct](https://kaitai.io/) definitions for Wii file formats — the WiiConnect24
channels, system files, a few games, and the Mobiclip video containers.

This merges two collections that had drifted apart:

* [RiiConnect24/Kaitai-Files](https://github.com/RiiConnect24/Kaitai-Files) — the broader
  system and channel coverage
* [WiiLink24/Kaitais](https://github.com/WiiLink24/Kaitais) — v3 channel variants, Terebi
  no Tomo, WC24 mail, Wii Fit Plus

76 definitions, all of which parse.

## Layout

```
channels/
  check_mii_out/     CMOC .ces list files + the shared list header
  everybody_votes/   voting.bin, first_data.bin, VotesCh.dat
  forecast/          forecast.bin, short.bin, savedata.dat
  news/              news.bin, savedata.dat
  nintendo/          dllist, .info (soft), thumbnail, dstrial — v6 and v3
  terebi_no_tomo/    Japanese TV guide: header, EPG, strings
system/              NAND, WC24 (download/friend/mail/send/recv), ticket + TMD,
                     Mii, SYSCONF, Wii Shop, play record, DHCP, IPL save
games/               Mario Kart Wii, My Pokémon Ranch, Wii Fit Plus, room.xml.bin,
                     Animal Crossing City Folk DLC items (.bitm), Swapdoodle BPK1 notes,
                     Super Smash Bros. Brawl's PAC archive
media/               Mobiclip — Wii, DS, .mods, .moflex, .vx
nitro/               the DS SDK generation — NSBMD model containers
nw4r/                NintendoWare for Revolution — the BRRES archive and its
                     MDL0/TEX0/PLT0 members, BRLYT layouts, BRLAN layout
                     animation, BRFNT bitmap fonts
nw4c/                the 3DS/Wii U generation — SARC archives, BFLYT layouts,
                     BFLAN layout animation, BFLIM images, BCH model
                     containers, Wii U BFRES model containers
```

## Verifying against a real console

Where a definition says something is *validated*, that means the console's own parser
enforces it, and the cited address is a runtime virtual address in the retail DOL:

| Channel | Title | Content |
|---|---|---|
| Forecast (USA v7) | `0001000248414645` | `00000001.app` |
| News (USA v7) | `0001000248414745` | `00000001.app` |
| Everybody Votes (USA v512) | `0001000248414A45` | `00000001.app` |
| Check Mii Out (USA v512) | `0001000248415045` | `00000001.app`, `00000004.app` |
| Nintendo Channel (USA v1792) | `000100024841464A` | `00000001.app` |

The other cross-check used throughout is the WiiLink24 Go generators, which write with
big-endian `binary.Write` — their structs are byte-exact wire layouts, so a Go struct that
computes to *N* bytes and a console that rejects anything smaller than *N* are two
independent measurements of the same number.

## Notes on specific definitions

### `nintendo/ninch_dllist.ksy` — the header is `0x5EA` bytes, not `0x95`

A `0x95`-byte header is often documented here. The console's validator
(`0x80035F60`) requires every table offset to be `>= 0x5EA`, which is the parser stating
where the header ends; real catalogs put the first table at exactly `0x5EA`.

The validator is also the proof that bytes `0x25`–`0xA4` are a **uniform directory of
sixteen `(count, offset)` pairs** rather than a mixture of named fields and unknown blobs:
it applies byte-for-byte identical code to all sixteen, at `0x25, 0x2D, 0x35, 0x3D, 0x45,
0x4D, 0x55, 0x5D, 0x65, 0x6D, 0x75, 0x7D, 0x85, 0x8D, 0x95, 0x9D`. Four of those slots
(`0x65`, `0x75`, `0x7D`, `0x8D`) are validated but populated by no known generator — they
are directory slots, not padding.

A second, independent witness sits right after the validator: the accessor constructor at
`0x80036380` takes sixteen `addi rN, r4, <disp>` at the same sixteen displacements, with no
conditionals, and writes them out as sixteen `{slot_ptr, file_base}` pairs at `accessor+8i`.
Slots 9, 11, 12 and 14 get live accessors built for them exactly like the eight populated
ones — they are directory slots, not padding, and their entry format is simply unsampled.

The `videos_1` field name is `videos` here, because "videos_1" next to
`recent_recommendations` invites exactly the mix-up documented below.

> Documentation that places a `videos1` table at `0x85`/`0x89` is wrong; this definition
> has it right as `recent_recommendations`. The arithmetic settles it without
> needing the binary: in a real 1,598,720-byte catalog that slot has count 1,320 at offset
> `0x164324`, which at the 234-byte video stride would end 169,140 bytes past EOF. At the
> 6-byte recommendation stride it fits.

### `check_mii_out/first.ksy` — `0x04`–`0x07` is one `u4`

It was split into `id1 (u1) / id2 (u2) / country_code (u1)`. Those are the same bytes as
the `u4` country field that `con_info.ksy` and `mii_list.ksy` declare — and because the
field is big-endian and country codes fit in a byte, the split happened to land
`country_code` on the correct byte while hiding the structure. Byte `0x02`, previously
undifferentiated padding, is the service-discontinued flag.

### `check_mii_out/cmoc_header.ksy`

The 0x20-byte header shared by every CMOC list file, the sub-record header, and the full
tag enum. Three separate CMOC definitions each described this block differently; rather
than silently editing all three, this documents the reconciliation.

The enum includes four tags that appear in no published table — `ER` (`0x4552`),
`XC` (`0x5843`), `XM` (`0x584D`) and `XX` (`0x5858`) — recovered by sweeping the retail
binary for the `li r3, <tag>; blr` getter pattern. **`XC`, `XM` and `XX` are category
tags, not record types**, and the binary carries their membership predicates:
`isXC` accepts `XC`/`PC`/`RC`/`CC`, `isXM` accepts `XM`/`PM`/`IM`/`CM`, and `isXX`
accepts the union plus `XX`. Do not write them into a file.

### `forecast/forecast_savedata.ksy`, `news/news_savedata.ksy` — new

Both channels' complete save files, at `.../data/noerase/savedata.dat`. They share one
32-byte container — a four-byte label (`HAF0` / `HAG0`), a payload, and a trailing CRC-32
over everything before it (standard reflected CRC-32, poly `0xEDB88320`, init `0xFFFFFFFF`,
final inversion). Both definitions carry the validator addresses and Nintendo's own two
failure strings, `NAND data broken.` and `NAND data invalid label.`

Two things a generator has to get right, both recorded in the `doc:` blocks:

* The trailing reserved bytes (8 in Forecast, 12 in News) are never read *and never
  written* — the save routine fills only the payload and the trailer, so on a first save
  they hold whatever the allocator left. The CRC covers them, so write zeros.
* News's `text_speed` at `0x0C` is **not bounds-checked**. The `0..=6` test in that loader
  applies to `news_language` at `0x08`, not to this field, so a value outside `0..7` reads
  a float past the end of an eight-entry table — reachable with an otherwise valid save.

### `check_mii_out/conresult.ksy` — new

The `conresult.cgi` response body. Worth a definition of its own because it is the one
CMOC payload that is served raw: no "MC" container, no AES, no LZ10, no signature — just
a bare array of 0x60-byte records with no file header.

### `games/accf_dlc_bitm.ksy` — new, and a different kind of source

Every other definition here traces back to a retail binary or a console-side validator.
This one doesn't: Animal Crossing City Folk's DLC items were never dumped from a retail
source, so this documents the `.bitm` format as read and written by ACDLC, the community
item editor/creator. The tool's build directory ships no `acdlc.py` — only a PyInstaller
app — so the layout came from extracting its bundled `bitm.py` module out of the frozen
app's PYZ archive and reading the Python 3.10 bytecode directly (no matching decompiler
was available for that bytecode version). Every offset, the nybble-packed flag block, the
one-hot `furniture_genre_1`/`furniture_genre_2` encoding, and the non-zero CRC-32 seed
were then cross-checked by round-tripping a real `.bitm` built with the tool's own
extracted `pack()` through the compiled `.ksy` — all fields matched byte-for-byte except
the fixed-width name strings, where Kaitai (correctly) keeps the trailing NUL padding that
ACDLC strips at the application layer.

## Constraints newly recorded

Contracts a generator has to satisfy, now in `doc:` blocks instead of being folklore:

* **`forecast/forecast_file.ksy`** — Nintendo's internal names for all seven tables,
  recovered from the validator string pool at `0x80199D10` where they appear in
  header-field order. Includes the warning that this file's `short_forecast_table`
  (Nintendo: `WeatherSummary`) is **not** `short.bin` (Nintendo: `WeatherNow`) — the most
  common third-party error about this format, usually arrived at by measuring the
  summary entry's `0x48` stride and assuming it is `short.bin`'s.
* **`forecast/forecast_file_short.ksy`** — `short.bin` has no condition table of its own;
  its codes are validated against `forecast.bin`'s (the console reads the count from
  `forecast.bin+0x30` while walking `short.bin`'s entries), so the pair must be generated
  together.
* **`news/news_file.ksy`** — the full validator contract at `0x8000B1EC`: version high
  bits, the two boolean flags, the `0xFF`-terminated language list, `message_offset`
  alignment, and `offset + count * size <= filesize` plus 4-byte alignment for all five
  checked tables (entry sizes `0x0C`, `0x2C`, `0x1C`, `0x10`, `0x18`). The headlines table
  is *not* checked. The console holds 24 of these — one per hour — and revalidates the
  whole set each pass.
* **`everybody_votes/votes.ksy`** — the header is deliberately **packed**: the `u4`
  offsets at `0x15`, `0x1A`, `0x1F`, `0x2A`, `0x35`, `0x3B` and `0x41` sit on odd
  addresses and the console reads them with unaligned `lwz`. Do not add alignment padding.
  Also the exact size bounds and the 2007–2036 timestamp window that rejects a whole pack.

## Known unresolved

* **CMOC `RC` (extended artisan) tail, `0x5C`–`0x5F`.** One reading has a `u2` country
  code at `0x5C` with padding at `0x5E`; another has an "arrow direction" byte at `0x5D`
  and a `u1` country code at `0x5E`. Only the first closes correctly against the embedded
  `RK` record at `0x60`. The `RC` call sites in the binary are request builders
  (`0x8006F3FC`), not layout parsers, so this needs a real `popcrafts_list.ces`.
* **`dllist` slots 9, 11, 12, 14** (`0x65`, `0x75`, `0x7D`, `0x8D`) — validated by the
  console and given live accessors, populated by nobody. Entry format unknown.
* **The CMOC `ER` tag** (`0x4552`) — has a getter, is referenced by no category predicate,
  and no payload has been observed.
* **Forecast `location_zoom_2`** (`+0x15` of a Places entry) — bounds-checked to `<= 3` and
  then read by nothing. `location_zoom_1` is resolved (a 0..9 prominence rank; see
  `forecast_file.ksy`), but this one has no consumer in the client at all.
* **What the Forecast `attribute` byte at `+0x0C` of the long and summary entries *means*.**
  Its type, range and validators are now pinned (`u8`, `<= 5` or `0xFF`, rejects the file),
  but nothing in this title reads it, so its semantics have to come from whatever does. A
  retail file gives it 1 for most cities, 5 for a few (Evansville, Gary, Bowling Green, El
  Paso), 4 for a few others (Brasília, Nuuk, Palikir), and 0xFF throughout on Japanese
  versions; a time-zone-ID theory (Nuuk sits in its own zone despite Denmark's country
  code) is unconfirmed
  ([ForecastChannel #5](https://github.com/WiiLink24/ForecastChannel/issues/5)).
* **The `unknown` `u4` at `+0x04` of every CMOC sub-record header.** Read by the display
  code; nothing found that branches on it.

## Credits

Original work by the [RiiConnect24](https://github.com/RiiConnect24) and
[WiiLink24](https://github.com/WiiLink24) projects and their contributors. Both sets are
kept intact here; corrections are limited to the items above and are described rather than
applied silently.

Merge and corrections by [quatric](https://github.com/quatric).

General questions or comments can be sent to
[quatricsoftware@gmail.com](mailto:quatricsoftware@gmail.com). No support is provided.

Companion reverse-engineering write-ups for the channels these describe:
[Forecast](https://gist.github.com/quatric/23267cf80416303da28ef186551a88df) ·
[News](https://gist.github.com/quatric/e571ed2400339867bf9d52701e59db24) ·
[Everybody Votes](https://gist.github.com/quatric/0b852dbe7f4921eed685cdd2ec3bf021) ·
[Check Mii Out](https://gist.github.com/quatric/a54c689066e97770488a880e5e355329) ·
[Nintendo Channel](https://gist.github.com/quatric/d8bb5b80c1a7fb0db9f845a4926aaa75)

Copyright (c) 2026 quatric

### `nw4r/` — checked against a retail disc, not a wiki

Every definition in `nw4r/` was compiled and run over the full contents of an
Animal Crossing: City Folk disc, and each carries assertions that would have
caught a plausible misreading rather than just "it parsed":

| Definition | Corpus | Cross-check that had to hold |
|---|---|---|
| `brres.ksy` | 4625 archives | `num_sections` equals the walked sub-file count plus one |
| `mdl0.ksy` | 7864 models | every model, bone, object and material name resolves in the string pool |
| `tex0.ksy` | 12368 textures | `len_file - ofs_data` matches the mipmap chain the format fields imply |
| `plt0.ksy` | 7095 palettes | `len_file` equals `ofs_data + num_entries * 2` exactly |
| `brlyt.ksy` | 250 layouts | `ofs_text + len_text` stays inside the section for all 547 text boxes |
| `brlan.ksy` | 1303 animations | 24748 curves and 48418 keyframes, every key list the length its curve declares |
| `brfnt.ksy` | 11 fonts | 491 sheets each exactly `len_sheet` bytes; all three CMAP encodings exercised |

Four things in these formats are quietly destructive to get wrong, in the sense
that the file still parses and simply yields the wrong answer.

**MDL0's section table is 13 entries at version 10, not 14.** It is 11 at
versions 8 and 9, 13 at version 10, and 14 at version 11. Getting the count
wrong does not break the section lookups — those are indexed — but it moves
`ofs_name` and the properties block, so the model silently loses its name and
reports a garbage bounding box. Version 10 is rare enough to hide this:
exactly one model out of 7864 on the disc uses it, and that one model is how
the error surfaced.

**BRLYT uses two different offset bases in the same file.** `txl1` and `fnl1`
name offsets are relative to the start of their entry table, twelve bytes into
the section; `mat1` and `txt1` offsets are relative to the start of the section
including its tag. Both were pinned down by locating the strings independently
and subtracting.

**A BRLYT `txt1` stores the reserved length before the used one.** A layout
holding a 34-character Japanese message writes 362 then 68. Reading them the
other way round asks for 362 bytes out of a section with 68 left, which is a
crash rather than a silent error — but only for text that does not fill its
buffer, so an all-ASCII test set never trips it.

**A BRRES folder does not have to contain BRRES sub-files.** Retail archives
carry an `External` folder holding whole foreign files — a `.brseq` sequence
and a `.bfs` whose first bytes are `01 b3 00 00`. `brres.ksy` therefore names
the sub-file types it will parse instead of applying a catch-all, and leaves
anything else as raw bytes; inventing a magic, a size and a version out of a
`.bfs`'s first sixteen bytes is worse than not parsing it.

One more, less dangerous but easy to trip over: **BRFNT offsets are absolute
file offsets that point at section bodies, not at section tags.** `FINF`'s
`ofs_tglp` reads 56 on a font whose `TGLP` section starts at 48. The same
eight-byte skew applies to the `CWDH` and `CMAP` chains.

### `nw4c/` — the 3DS and Wii U generation

Same approach as `nw4r/`: compiled, run over a real corpus, and asserted
against something that would have caught a misreading. The corpus is the
twenty layout archives shipped inside Swapdoodle, and the definitions chain —
`sarc.ksy` unpacks the archives, and the 1866 files it yields are what the
other three were checked against.

| Definition | Corpus | Cross-check that had to hold |
|---|---|---|
| `sarc.ksy` | 20 archives, 1866 members | every member's path hash recomputed from its name and matched |
| `bflyt.ksy` | 299 layouts | 2209 material names clean ASCII; text offsets inside their sections |
| `bflan.ksy` | 900 animations | 19457 curves and 54622 keys, every key list the length its curve declares |
| `bflim.ksy` | 667 images | `len_data * 8` equals padded width × height × the format's bit depth |
| `bch.ksy` | 3 containers | relocation table ends exactly at EOF; all 209 dictionary names resolve in the string table |

The field widths grew from the Wii formats and nothing in the files announces
them, so each was measured rather than assumed: a BFLYT pane name is 24 bytes,
a material name 28, a group name 34, and a group's pane references 24 each; a
BFLAN animation entry's name is 28 and its `pat1` group names sit on a 36-byte
stride. The material width is a good example of how these were settled —
across 2209 materials, reading the field as 32 bytes fails on 455 of them
while 28 holds for all.

**A BFLIM's header is at the end of the file.** Image data starts at offset 0
and a fixed 40-byte `FLIM`+`imag` trailer follows it, so a BFLIM begins with
whatever its first texels happen to be and cannot be identified by its leading
bytes. That trailer is also what makes the format enum verifiable rather than
inherited: 3DS textures are padded to power-of-two dimensions, so dividing
`len_data` by the padded pixel count yields the bit depth directly, and it
comes out exact for all eleven formats present.

**Kaitai note, for anyone extending these.** Two compiler behaviours cost real
time here, both in the Python target. A type whose endianness is computed from
an expression has *every* positional instance compiled behind a test on the
very flag being decided, so a byte-order mark read as an instance of the same
type cannot drive it — `sarc.ksy` reads the mark in a plain outer type and
passes the answer down as a parameter, and nests everything that must follow
that order inside the parameterised type, since a sibling type would silently
inherit the file default instead. Separately, `_index` used inside an
`instances` `pos:` expression miscompiles into an unbound loop variable; the
fix is a one-field `*_ref` type that holds the offset and resolves it.

**`bch.ksy` covers the container, not the content.** A BCH's six regions chain
end to end and the last one finishes exactly at EOF, which is the cheapest way
to confirm a correct read. Its main header is fifteen content groups, each a
*(pointer table offset, count, dictionary offset)* triple relative to the main
header — fifteen is self-evident in the files, since the first dictionary sits
at 0xb4, exactly fifteen twelve-byte triples in. The group ordering is
confirmed semantically rather than assumed: the Mii body container reports one
model named `Mii_body_00`, two materials and two textures (`body`, `Mii_Pen`);
its animation counterpart reports 62 skeletal and 62 material animations; and
the shared-data container reports 63 shaders, whose names are all
`N@DefaultShader`.

What the definition deliberately stops short of is the content itself. Model,
material and animation bodies are pre-baked PICA200 register programs, and
turning those into geometry is a different job from parsing a container. The
dictionaries give every object's name and the pointer tables give where each
body starts.

### `games/pac.ksy`, `nw4c/bfres.ksy`, `nitro/nsbmd.ksy` — new

Added from the same sibling project's ground truth (`wiimms-szs-tools-nintendo`,
`lib-nintendo.c`/`lib-bfres.c`/`lib-nsbmd.c`), each against real retail or
real-tooling samples rather than any format wiki:

| Definition | Corpus | Cross-check that had to hold |
|---|---|---|
| `games/pac.ksy` | 17 archives (all of a Brawl disc's `fighter/Fit*.pac`) | every entry's `data`/`pad` walk lands exactly on the next 0x20-aligned header, through files with up to 13 entries |
| `nw4c/bfres.ksy` | 2 (Splatoon's `SPL_box_duck.bfres`, a Wii U System Settings `gsys.bfres`) | full FMDL→FVTX/FSHP→index-buffer chain resolves on the first; index buffer size equals `index_count * 2` exactly |
| `nitro/nsbmd.ksy` | 6 (`giratina`/`giratina_portal`/`giratina_face`/`kawashima`/`crystal`/`ug_base_cur.nsbmd`) | every shape header's tag reads the constant `0x00100000`; `giratina.nsbmd`'s 27-bone dictionary and `kawashima.nsbmd`'s facial-rig bone names match this project's own prior cross-checks |

**PAC's `name` field is not the fixed template string a single sample
suggests.** Five of the seventeen real files carry `FitPeach`, but two carry
`FitSonic`, and every `*MotionEtc.pac`/`*Final.pac` carries a name matching
*that* file's own character and suffix instead. **PAC's first entry is not
always raw `MiscData` either** — every `*Final.pac` (Final Smash
transformations) instead packs each entry's data as a nested `bres` (BRRES)
resource, and `FitPeachFinal.pac`'s second entry is a whole nested `ARC\0`
archive embedded inside another PAC archive's entry. See `pac.ksy`'s doc
block for the full breakdown.

**BFRES's pointers are self-relative to the field, not to any shared
base**, unlike BRRES (relative to the enclosing group) or BCH (relative to
the main header) — every offset's stored value is added to that offset
*field's own* file address. Getting this wrong the first time round produced
a `buffer_info.data_addr` that computed from `_io.pos` at the moment it was
*read* rather than from the field's fixed position, which happened to work
for the first buffer accessed in program order and silently pointed at the
wrong address for every other — caught only because a later cross-check
(`index_buffer.len_data == index_count * 2` on a real file) forced computing
the address a second, independent way and comparing. Fixed by threading an
explicit `base` parameter through every type with a self-relative pointer,
same fix this project's own `nw4c/` notes below already document for the
general "`_index` inside a `pos:` expression miscompiles" Kaitai/Python
pitfall — this was the same bug's less obvious sibling, `_io.pos` used
*inside an instance* rather than *inside a repeat*.

**NSBMD's model dictionary and shape dictionary use different bases for
their entries' stored offsets**, and it isn't a copy-paste inconsistency in
this definition — it matches the reference C exactly. The model
dictionary's one entry is relative to the `MDL0` block's own start, eight
bytes before the dictionary header that contains it; the shape dictionary's
entries are relative to the shape dictionary's own header address, no skew.
Both were confirmed by resolving the pointer each way and checking that it
lands on a real `MDL0` tag and a real `0x00100000` shape tag respectively,
not assumed from either format alone.

### Not yet covered

BCLYT, BCLAN, BCFNT, BNTX and CGFX/BCRES still have no definitions here
because there is still no real sample on this machine to check them
against — confirmed again this session with a fresh sweep (`mdfind` plus a
disc-image/CIA search) rather than reusing the earlier "no sample" finding
verbatim; nothing turned up. GFA (Good-Feel's `GFAC` container, Kirby's
Epic Yarn / Wario Land Shake It) and DARC (the 3DS "differential archive",
`darc` magic — Tomodachi Life's `romfs/layout/*.bin`) are in the same boat:
this project's own sibling repo validated both against a real disc/CIA
during its own development, but neither the WBFS/CIA nor an unpacked
extraction survives on this machine now, and `ctrtool` (present) has
nothing to extract without the original `.cia`. Writing any of the five
would mean shipping structure that has never been run against real data on
this side, which is the one thing every other definition in this
repository can claim. BFRES's Wii U flavour (version 3.x, big-endian) is
now covered above; the Switch flavour that reuses the same `FRES` magic
(version 9+, little-endian, a separate BNTX for textures) is a different
enough layout that it is treated as a distinct, still-uncovered format
rather than a variant of `bfres.ksy`.
