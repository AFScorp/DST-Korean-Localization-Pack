fallback_tradein = {
	"emoji",
	"controllers",
	GLOBAL.TALKINGFONT_TRADEIN,
	GLOBAL.FALLBACK_FONT_OUTLINE,
	GLOBAL.FALLBACK_FONT_FULL_OUTLINE,
}
local TALKINGFONT_TRADEIN_KR = "talkingfont_tradein_kr"

table.insert(GLOBAL.FONTS, {filename = MODROOT.."fonts/talkingfont_tradein_kr.zip", alias = TALKINGFONT_TRADEIN_KR, fallback = fallback_tradein})  

AddPrefabPostInit("yotb_stage", function(inst)
    inst.components.talker.font = TALKINGFONT_TRADEIN_KR
end)