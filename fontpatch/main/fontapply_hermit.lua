fallback_hermit = {
	"emoji",
	"controllers",
	GLOBAL.TALKINGFONT_HERMIT,
	GLOBAL.FALLBACK_FONT_OUTLINE,
	GLOBAL.FALLBACK_FONT_FULL_OUTLINE,
}
local TALKINGFONT_HERMIT_KR = "talkingfont_hermit_kr"

table.insert(GLOBAL.FONTS, {filename = MODROOT.."fonts/talkingfont_hermit_kr.zip", alias = TALKINGFONT_HERMIT_KR, fallback = fallback_hermit})  

AddPrefabPostInit("hermitcrab", function(inst)
    inst.components.talker.fontsize = 40
    inst.components.talker.font = TALKINGFONT_HERMIT_KR
end)