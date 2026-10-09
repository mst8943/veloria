extends RefCounted

const CORE := ["arden", "voss", "kessler", "halden", "prens"]

## The inputs are visible UI state; no simulation state is read here.
static func strip_ids(week: int, guide: bool, advisors: Array, changes: Array, danger: Array, selected: String, last_acted: String) -> Array:
	if guide and week <= 3:
		return CORE.duplicate()
	var result := []
	for source in [advisors, changes, danger, [selected], [last_acted], CORE]:
		for id in source:
			if id != "" and not result.has(id):
				result.append(id)
				if result.size() == 5:
					break
		if result.size() == 5:
			break
	if selected != "" and not result.has(selected):
		result[4] = selected
	return result
