local fallback_wormwood = {
	"emoji",
	"controllers",
	GLOBAL.TALKINGFONT_WORMWOOD,
	GLOBAL.FALLBACK_FONT_OUTLINE,
	GLOBAL.FALLBACK_FONT_FULL_OUTLINE,
}
local TALKINGFONT_WORMWOOD_KR = "talkingfont_wormwood_kr"

table.insert(GLOBAL.FONTS, {filename = MODROOT.."fonts/talkingfont_wormwood_kr.zip", alias = TALKINGFONT_WORMWOOD_KR, fallback = fallback_wormwood})  

AddPrefabPostInit("wormwood", function(inst)
    inst.components.talker.fontsize = 40
    inst.components.talker.font = TALKINGFONT_WORMWOOD_KR
end)

--modmain에 직접 옮겨넣거나 modimport 기능을 사용하세요
