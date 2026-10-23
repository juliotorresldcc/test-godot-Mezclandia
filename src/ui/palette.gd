class_name Palette
extends RefCounted
## Tokens de color (art-direction.md ART-001). tools/check_sync.py verifica que coinciden.

const BG_NIGHT := Color("#070B1F")
const BG_DEEP := Color("#0E1A4D")
const BG_SURFACE := Color("#151E48")
const BG_SURFACE_ALT := Color("#1F2A60")
const ORB_CYAN := Color("#00E5FF")
const ORB_MAGENTA := Color("#FF2BD6")
const ORB_YELLOW := Color("#FFE14D")
const ORB_VIOLET := Color("#A47CFF")
const ORB_CRYSTAL := Color("#E8F4FF")
const TEXT_PRIMARY := Color("#F2F5FF")
const TEXT_SECONDARY := Color("#A9B3D9")
const TEXT_ON_ACCENT := Color("#070B1F")
const UI_ACCENT := Color("#00E5FF")
const UI_GLYPH := Color("#070B1F")

const ORB_COLORS: Array[Color] = [ORB_CYAN, ORB_MAGENTA, ORB_YELLOW, ORB_VIOLET, ORB_CRYSTAL]


static func orb(kind: int) -> Color:
	return ORB_COLORS[kind]


static func alpha(color: Color, value: float) -> Color:
	return Color(color, value)
