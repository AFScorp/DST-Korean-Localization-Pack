local TALKINGFONT_WX78_KR = "talkingfont_wx78_kr"

table.insert(GLOBAL.FONTS, {filename = MODROOT.."fonts/talkingfont_wx78_kr.zip", alias = TALKINGFONT_WX78_KR, fallback = GLOBAL.DEFAULT_FALLBACK_TABLE_OUTLINE})  

AddPrefabPostInit("wx78", function(inst)
    inst.components.talker.fontsize = 30
    inst.components.talker.font = TALKINGFONT_WX78_KR
end)