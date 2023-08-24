local Levels = require("map/levels")
local playstyles = Levels.GetPlaystyles()

for _, playstyle in pairs(playstyles) do
	local playstyledef = Levels.GetPlaystyleDef(playstyle)
	local id = playstyledef.default_preset
	--print("Playstyle id: ", id)

	playstyledef.name = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS[id]
	playstyledef.desc = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC[id]
end
