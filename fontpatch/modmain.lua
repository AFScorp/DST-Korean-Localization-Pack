local _G = GLOBAL
local TheSim = _G.TheSim

--Wormwood alias & fallback table
local fallback_wormwood = {
	"emoji",
	"controllers",
	_G.TALKINGFONT_WORMWOOD,
	_G.FALLBACK_FONT_OUTLINE,
	_G.FALLBACK_FONT_FULL_OUTLINE,
}
_G.TALKINGFONT_WORMWOOD_KR = "talkingfont_wormwood_kr"

--Crabby Hermit alias & fallback table
local fallback_hermit = {
	"emoji",
	"controllers",
	_G.TALKINGFONT_HERMIT,
	_G.FALLBACK_FONT_OUTLINE,
	_G.FALLBACK_FONT_FULL_OUTLINE,
}
_G.TALKINGFONT_HERMIT_KR = "talkingfont_hermit_kr"

--WX-78 alias & fallback table
_G.TALKINGFONT_WX78_KR = "talkingfont_wx78_kr"

--Tradein alias & fallback table
local fallback_tradein = {
	"emoji",
	"controllers",
	_G.TALKINGFONT_TRADEIN,
	_G.FALLBACK_FONT_OUTLINE,
	_G.FALLBACK_FONT_FULL_OUTLINE,
}
_G.TALKINGFONT_TRADEIN_KR = "talkingfont_tradein_kr"

--font loading
AddSimPostInit(function()
	TheSim:UnloadFont(_G.resolvefilepath("fonts/talkingfont_wormwood_kr.zip"), _G.TALKINGFONT_WORMWOOD_KR)
	TheSim:UnloadFont(_G.resolvefilepath("fonts/talkingfont_wx78_kr.zip"), _G.TALKINGFONT_WX78_KR)
	TheSim:UnloadFont(_G.resolvefilepath("fonts/talkingfont_hermit_kr.zip"), _G.TALKINGFONT_HERMIT_KR)
	TheSim:UnloadFont(_G.resolvefilepath("fonts/talkingfont_tradein_kr.zip"), _G.TALKINGFONT_TRADEIN_KR)
	
	TheSim:UnloadPrefabs({"fontprefab"})
	
	local Assets = {
		Asset("FONT", _G.resolvefilepath("fonts/talkingfont_wormwood_kr.zip")),
		Asset("FONT", _G.resolvefilepath("fonts/talkingfont_hermit_kr.zip")),
		Asset("FONT", _G.resolvefilepath("fonts/talkingfont_wx78_kr.zip")),
		Asset("FONT", _G.resolvefilepath("fonts/talkingfont_tradein_kr.zip")),
	}
	local FontsPrefab = _G.Prefab("fontprefab", function() return _G.CreateEntity() end, Assets)
	_G.RegisterPrefabs(FontsPrefab)
	
	TheSim:LoadPrefabs({"fontprefab"})
	
    TheSim:LoadFont(_G.resolvefilepath("fonts/talkingfont_wormwood_kr.zip"), _G.TALKINGFONT_WORMWOOD_KR)
	TheSim:LoadFont(_G.resolvefilepath("fonts/talkingfont_wx78_kr.zip"), _G.TALKINGFONT_WX78_KR)
	TheSim:LoadFont(_G.resolvefilepath("fonts/talkingfont_hermit_kr.zip"), _G.TALKINGFONT_HERMIT_KR)
	TheSim:LoadFont(_G.resolvefilepath("fonts/talkingfont_tradein_kr.zip"), _G.TALKINGFONT_TRADEIN_KR)
	
	TheSim:SetupFontFallbacks(_G.TALKINGFONT_WORMWOOD_KR, fallback_wormwood)
	TheSim:SetupFontFallbacks(_G.TALKINGFONT_WX78_KR, _G.DEFAULT_FALLBACK_TABLE_OUTLINE)
	TheSim:SetupFontFallbacks(_G.TALKINGFONT_HERMIT_KR, fallback_hermit)
	TheSim:SetupFontFallbacks(_G.TALKINGFONT_TRADEIN_KR, fallback_tradein)
end)

AddPrefabPostInit("wormwood", function(inst)
    inst.components.talker.fontsize = 35
    inst.components.talker.font = _G.TALKINGFONT_WORMWOOD_KR
end)

AddPrefabPostInit("hermitcrab", function(inst)
    inst.components.talker.fontsize = 40
    inst.components.talker.font = _G.TALKINGFONT_HERMIT_KR
end)

AddPrefabPostInit("wx78", function(inst)
    inst.components.talker.fontsize = 30
    inst.components.talker.font = _G.TALKINGFONT_WX78_KR
end)

AddPrefabPostInit("yotb_stage", function(inst)
    inst.components.talker.font = _G.TALKINGFONT_TRADEIN_KR
end)

AddPrefabPostInit("yotb_stage_voice", function(inst)
    inst.components.talker.font = _G.TALKINGFONT_TRADEIN_KR
end)
