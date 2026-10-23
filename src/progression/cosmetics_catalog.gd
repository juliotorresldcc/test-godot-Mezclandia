class_name CosmeticsCatalog
extends RefCounted
## Catálogo de cosméticos (parameters.md §5, FR-PRG-010/011).

const CATEGORY_CORE: String = "core"
const CATEGORY_TRAIL: String = "trail"
const CATEGORIES: Array[String] = [CATEGORY_CORE, CATEGORY_TRAIL]

## id → {categoría, clave de nombre, precio, por defecto}
const ITEMS: Dictionary[String, Dictionary] = {
	"core_default": {"category": CATEGORY_CORE, "name": "COSMETIC_CORE_DEFAULT", "price": 0, "default": true},
	"core_pulsar": {"category": CATEGORY_CORE, "name": "COSMETIC_CORE_PULSAR", "price": 40, "default": false},
	"core_nebula": {"category": CATEGORY_CORE, "name": "COSMETIC_CORE_NEBULA", "price": 120, "default": false},
	"core_singularity": {"category": CATEGORY_CORE, "name": "COSMETIC_CORE_SINGULARITY", "price": 300, "default": false},
	"trail_default": {"category": CATEGORY_TRAIL, "name": "COSMETIC_TRAIL_DEFAULT", "price": 0, "default": true},
	"trail_spark": {"category": CATEGORY_TRAIL, "name": "COSMETIC_TRAIL_SPARK", "price": 40, "default": false},
	"trail_comet": {"category": CATEGORY_TRAIL, "name": "COSMETIC_TRAIL_COMET", "price": 120, "default": false},
	"trail_aurora": {"category": CATEGORY_TRAIL, "name": "COSMETIC_TRAIL_AURORA", "price": 300, "default": false},
}


static func exists(id: String) -> bool:
	return ITEMS.has(id)


static func category_of(id: String) -> String:
	return ITEMS[id]["category"]


static func price_of(id: String) -> int:
	return ITEMS[id]["price"]


static func name_key(id: String) -> String:
	return ITEMS[id]["name"]


static func items_in(category: String) -> Array[String]:
	var result: Array[String] = []
	for id: String in ITEMS:
		if ITEMS[id]["category"] == category:
			result.append(id)
	return result


static func default_for(category: String) -> String:
	for id: String in items_in(category):
		if ITEMS[id]["default"]:
			return id
	return ""
