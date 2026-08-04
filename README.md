# Wii-Kaitai

[Kaitai Struct](https://kaitai.io/) definitions for Wii file formats — the WiiConnect24
channels, system files, a few games, and the Mobiclip video containers.

This merges two collections that had drifted apart:

* [RiiConnect24/Kaitai-Files](https://github.com/RiiConnect24/Kaitai-Files) — the broader
  system and channel coverage
* [WiiLink24/Kaitais](https://github.com/WiiLink24/Kaitais) — v3 channel variants, Terebi
  no Tomo, WC24 mail, Wii Fit Plus

57 definitions, all of which parse.

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
games/               Mario Kart Wii, My Pokémon Ranch, Wii Fit Plus, room.xml.bin
media/               Mobiclip — Wii, DS, .mods, .moflex, .vx
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
  but nothing in this title reads it, so its semantics have to come from whatever does
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
