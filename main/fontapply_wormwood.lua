local TALKINGFONT_WORMWOOD_KR = "talkingfont_wormwood_kr"

table.insert(GLOBAL.FONTS, {filename = MODROOT.."fonts/talkingfont_wormwood_kr.zip", alias = TALKINGFONT_WORMWOOD_KR, fallback = GLOBAL.DEFAULT_FALLBACK_TABLE_OUTLINE})  

AddPrefabPostInit("wormwood", function(inst)
    inst.components.talker.fontsize = 40
    inst.components.talker.font = TALKINGFONT_WORMWOOD_KR
end)
