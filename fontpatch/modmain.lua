--Wormwood alias & fallback table
local fallback_wormwood = {
	"emoji",
	"controllers",
	GLOBAL.TALKINGFONT_WORMWOOD,
	GLOBAL.FALLBACK_FONT_OUTLINE,
	GLOBAL.FALLBACK_FONT_FULL_OUTLINE,
}
local TALKINGFONT_WORMWOOD_KR = "talkingfont_wormwood_kr"

--Crabby Hermit alias & fallback table
local fallback_hermit = {
	"emoji",
	"controllers",
	GLOBAL.TALKINGFONT_HERMIT,
	GLOBAL.FALLBACK_FONT_OUTLINE,
	GLOBAL.FALLBACK_FONT_FULL_OUTLINE,
}
local TALKINGFONT_HERMIT_KR = "talkingfont_hermit_kr"

--WX-78 alias & fallback table
local TALKINGFONT_WX78_KR = "talkingfont_wx78_kr"

--Tradein alias & fallback table
local fallback_tradein = {
	"emoji",
	"controllers",
	GLOBAL.TALKINGFONT_TRADEIN,
	GLOBAL.FALLBACK_FONT_OUTLINE,
	GLOBAL.FALLBACK_FONT_FULL_OUTLINE,
}
local TALKINGFONT_TRADEIN_KR = "talkingfont_tradein_kr"

--font table
local fonts = {
	{filename = MODROOT.."fonts/talkingfont_wormwood_kr.zip", alias = TALKINGFONT_WORMWOOD_KR, fallback = fallback_wormwood},
	{filename = MODROOT.."fonts/talkingfont_hermit_kr.zip", alias = TALKINGFONT_HERMIT_KR, fallback = fallback_hermit},
	{filename = MODROOT.."fonts/talkingfont_wx78_kr.zip", alias = TALKINGFONT_WX78_KR, fallback = GLOBAL.DEFAULT_FALLBACK_TABLE_OUTLINE},
	{filename = MODROOT.."fonts/talkingfont_tradein_kr.zip", alias = TALKINGFONT_TRADEIN_KR, fallback = fallback_tradein},
}

--loads font
for i, v in ipairs(fonts) do
	table.insert(GLOBAL.FONTS, v)
end

AddPrefabPostInit("wormwood", function(inst)
    inst.components.talker.fontsize = 35
    inst.components.talker.font = TALKINGFONT_WORMWOOD_KR
end)

AddPrefabPostInit("hermitcrab", function(inst)
    inst.components.talker.fontsize = 40
    inst.components.talker.font = TALKINGFONT_HERMIT_KR
end)

AddPrefabPostInit("wx78", function(inst)
    inst.components.talker.fontsize = 30
    inst.components.talker.font = TALKINGFONT_WX78_KR
end)

AddPrefabPostInit("yotb_stage", function(inst)
    inst.components.talker.font = TALKINGFONT_TRADEIN_KR
end)

AddPrefabPostInit("yotb_stage_voice", function(inst)
    inst.components.talker.font = TALKINGFONT_TRADEIN_KR
end)
